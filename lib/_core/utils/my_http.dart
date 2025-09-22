import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/members/providers/member_auth_provider.dart';
// import '../sessions/session_repository.dart'; // 삭제
import '../../domain/members/repositories/member_auth_repository.dart'; // tokenKey를 사용하기 위해 추가

/// todo - 개인 로컬 컴퓨터 주소로 수정하세요
/// 기본 서버 주소 - http://125.134.0.135:8080/api
/// 팀장 서버 주소 - http://192.168.0.128:8080/api
/// 자기 서버 주소 - http://10.0.2.2:8080/api
/// 모바일 테스트용 서버 - https://port-0-market-place-server-m9sgwbay02179a7c.sel4.cloudtype.app/api
const baseUrl = "http://10.0.2.2:8080/api";

final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => true, // 모든 상태 코드를 성공으로 간주하고 인터셉터에서 처리
    connectTimeout: const Duration(seconds: 30), // 연결 타임아웃 30초로 설정
    receiveTimeout: const Duration(seconds: 30), // 응답 수신 타임아웃 30초로 설정
  ),
);

const secureStorage =
    FlutterSecureStorage(); // 이 파일에서 직접 사용되는 secureStorage 인스턴스 유지

// setupInterceptors는 AuthNotifier 인스턴스를 받아 인터셉터를 설정합니다.
void setupInterceptors(AuthNotifier authNotifier) {
  dio.interceptors.clear(); // 기존 인터셉터 초기화 (중복 등록 방지)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        // 인증이 필요 없는 경로 목록
        final publicPaths = [
          '/members/login',
          '/members/register',
          '/members/check-id',
          '/email/register/send-code',
          '/email/register/confirm-code',
          '/email/account/find-id/masked',
          '/email/account/find-id/send-email',
          '/email/account/password/send-code',
          '/email/account/password/confirm-code',
          '/email/account/password/reset',
          '/members/login/social',
        ];

        bool isPublicPath =
            publicPaths.any((publicPath) => path.endsWith(publicPath));

        if (!isPublicPath) {
          // MemberAuthRepository에 정의된 tokenKey를 사용 (임포트 추가됨)
          final accessToken = await secureStorage.read(key: tokenKey);
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $accessToken";
            print(
                "AuthInterceptor (onRequest): Token header added for ${options.path}");
          } else {
            print(
                "AuthInterceptor (onRequest): No access token found for protected route ${options.path}");
          }
        } else {
          print(
              "AuthInterceptor (onRequest): Token header not added (public path): ${options.path}");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print(
            "AuthInterceptor (onResponse): Received response for ${response.requestOptions.path}, Status: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print(
            "AuthInterceptor (onError): Error on ${e.requestOptions.path}, Status: ${e.response?.statusCode}");
        if (e.response?.statusCode == 401) {
          print(
              "AuthInterceptor: Detected 401 Unauthorized error. Path: ${e.requestOptions.path}");

          String serverMessage =
              "세션이 만료되었거나 다른 기기에서 로그인하여 자동으로 로그아웃됩니다. 다시 로그인해주세요.";

          if (e.response?.data != null) {
            dynamic responseData = e.response!.data;
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('message') &&
                  responseData['message'] is String &&
                  responseData['message'].isNotEmpty) {
                serverMessage = responseData['message'];
              } else if (responseData.containsKey('error') &&
                  responseData['error'] is Map<String, dynamic>) {
                final errorData = responseData['error'] as Map<String, dynamic>;
                if (errorData.containsKey('message') &&
                    errorData['message'] is String &&
                    errorData['message'].isNotEmpty) {
                  serverMessage = errorData['message'];
                }
              } else if (responseData.containsKey('detail') &&
                  responseData['detail'] is String &&
                  responseData['detail'].isNotEmpty) {
                serverMessage = responseData['detail'];
              }
            } else if (responseData is String && responseData.isNotEmpty) {
              serverMessage = responseData;
            }
          }

          print(
              "AuthInterceptor: Extracted server message for 401: \"$serverMessage\"");

          await authNotifier.handleSessionInvalidation(serverMessage);

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: "세션 만료 또는 동시 접속으로 인해 로그아웃 처리됨: $serverMessage",
              type: DioExceptionType.cancel,
            ),
          );
        }
        return handler.next(e);
      },
    ),
  );
}
