import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../domain/members/providers/member_auth_provider.dart';
import '../../domain/members/repositories/member_auth_repository.dart';

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
    validateStatus: (status) => true,
    connectTimeout: const Duration(seconds: 60), // 30초 -> 60초로 변경
    receiveTimeout: const Duration(seconds: 60), // 30초 -> 60초로 변경
  ),
);

const secureStorage = FlutterSecureStorage();

final logger = Logger();

void setupInterceptors(AuthNotifier authNotifier) {
  dio.interceptors.clear();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
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
          final accessToken = await secureStorage.read(key: tokenKey);
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $accessToken";
            logger.d("인증 인터셉터 (onRequest): 토큰 헤더 추가됨 - 경로: ${options.path}");
          } else {
            logger.w(
                "인증 인터셉터 (onRequest): 보호된 경로에 접근 토큰 없음 - 경로: ${options.path}");
          }
        } else {
          logger.v(
              "인증 인터셉터 (onRequest): 토큰 헤더 추가 안됨 (공개 경로) - 경로: ${options.path}");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        logger.i(
            "인증 인터셉터 (onResponse): 응답 수신 - 경로: ${response.requestOptions.path}, 상태: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        logger.e(
            "인증 인터셉터 (onError): 오류 발생 - 경로: ${e.requestOptions.path}, 상태: ${e.response?.statusCode}");
        if (e.response?.statusCode == 401) {
          logger.w("인증 인터셉터: 401 인증 오류 감지 - 경로: ${e.requestOptions.path}");

          String serverMessage = "인증 토큰이 만료되었습니다. 다시 로그인해주세요.";

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

          logger.w("인증 인터셉터: 401에 대한 추출/기본 서버 메시지: $serverMessage");

          await authNotifier.handleSessionInvalidation(serverMessage);

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: serverMessage,
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
