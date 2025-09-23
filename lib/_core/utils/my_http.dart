import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            print("인증 인터셉터 (onRequest): 토큰 헤더 추가됨 - 경로: ${options.path}");
          } else {
            print(
                "인증 인터셉터 (onRequest): 보호된 경로에 접근 토큰 없음 - 경로: ${options.path}");
          }
        } else {
          print(
              "인증 인터셉터 (onRequest): 토큰 헤더 추가 안됨 (공개 경로) - 경로: ${options.path}");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print(
            "인증 인터셉터 (onResponse): 응답 수신 - 경로: ${response.requestOptions.path}, 상태: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print(
            "인증 인터셉터 (onError): 오류 발생 - 경로: ${e.requestOptions.path}, 상태: ${e.response?.statusCode}");
        if (e.response?.statusCode == 401) {
          print("인증 인터셉터: 401 인증 오류 감지 - 경로: ${e.requestOptions.path}");

          // 토큰 만료에 대한 새로운 기본 메시지.
          String serverMessage = "인증 토큰이 만료되었습니다. 다시 로그인해주세요.";

          // 서버로부터 더 구체적인 메시지를 받을 수 있도록 파싱 로직 유지,
          // 하지만 기본값은 이제 일반적인 토큰 만료에 관한 것입니다.
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

          print("인증 인터셉터: 401에 대한 추출/기본 서버 메시지: $serverMessage");

          await authNotifier.handleSessionInvalidation(serverMessage);

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              // 수정된 DioException 오류 메시지
              error: serverMessage, // 단순화됨
              type: DioExceptionType.cancel,
            ),
          );
        }
        return handler.next(e);
      },
    ),
  );
}

final dioProvider = Provider<Dio>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  setupInterceptors(authNotifier);
  return dio;
});
