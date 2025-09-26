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
    validateStatus: (status) => true, // 모든 상태 코드를 onResponse에서 처리
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
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == false) {
          final errorData = data['error'];
          String errorMessage = "알 수 없는 오류가 발생했습니다.";

          if (errorData != null && errorData is Map<String, dynamic>) {
            if (errorData['validationErrors'] != null &&
                errorData['validationErrors'] is Map) {
              final validationErrors =
                  errorData['validationErrors'] as Map<String, dynamic>;
              errorMessage = validationErrors.values.join('\n');
            } else if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
          }

          final dioException = DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: errorMessage,
            type: DioExceptionType.badResponse,
          );

          logger.w(
              "인증 인터셉터 (onResponse): success:false 응답을 에러로 처리 -> $errorMessage");
          return handler.reject(dioException);
        }
        logger.i(
            "인증 인터셉터 (onResponse): 성공 응답 수신 - 경로: ${response.requestOptions.path}, 상태: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        logger.e(
            "인증 인터셉터 (onError): 오류 발생 - 경로: ${e.requestOptions.path}, 상태: ${e.response?.statusCode}, 메시지: ${e.error}");

        if (e.response?.statusCode == 401) {
          logger.w("인증 인터셉터: 401 인증 오류 감지. 세션을 무효화합니다.");
          final message = e.error?.toString() ?? "인증이 만료되었습니다. 다시 로그인해주세요.";
          await authNotifier.handleSessionInvalidation(message);

          // final 속성을 수정하는 대신, 새로운 예외 객체를 생성하여 전달합니다.
          return handler.reject(DioException(
            requestOptions: e.requestOptions,
            error: message,
            type: DioExceptionType.cancel, // 요청 취소로 처리
          ));
        }

        // onResponse에서 가공된 예외가 아닌 경우 (네트워크 오류 등)
        if (e.error is! String) {
          String friendlyMessage;
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            friendlyMessage = "네트워크 연결이 지연되고 있습니다. 잠시 후 다시 시도해주세요.";
          } else {
            friendlyMessage = "인터넷 연결을 확인해주세요.";
          }
          // 사용자 친화적 메시지를 담은 새로운 예외 객체를 생성하여 전달합니다.
          final newException = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            error: friendlyMessage,
            type: e.type,
          );
          return handler.next(newException);
        }

        // 다른 모든 오류는 그대로 상위로 전달
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
