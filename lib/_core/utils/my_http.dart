import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Import AuthNotifier
import '../../domain/members/providers/member_auth_provider.dart';

/// todo - 개인 로컬 컴퓨터 주소로 수정하세요
/// 팀장 서버 주소 - http://192.168.0.128:8080/api
/// 자기 서버 주소 - http://10.0.2.2:8080/api
/// 모바일 테스트용 서버 - https://port-0-market-place-server-m9sgwbay02179a7c.sel4.cloudtype.app/api
const baseUrl = "http://192.168.0.128:8080/api";

final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl, // 내 IP 입력
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => true,
  ),
);

const secureStorage = FlutterSecureStorage();

// Flag to prevent multiple token refresh attempts concurrently
bool _isRefreshing = false;

// Modify setupInterceptors to accept AuthNotifier
void setupInterceptors(AuthNotifier authNotifier) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        // 인증이 필요 없는 경로 목록
        final publicPaths = [
          '/members/login',
          '/members/register',
          '/members/check-id', // 아이디 중복 확인
          '/email/register/send-code', // 회원가입시 이메일 인증 코드 발송
          '/email/register/confirm-code', // 회원가입시 이메일 인증 코드 확인
          '/email/account/find-id/masked', // 아이디 찾기 (마스킹)
          '/email/account/find-id/send-email', // 아이디 찾기 (전체 아이디 이메일 발송)
          // --- 비밀번호 재설정 관련 공개 경로 추가 ---
          '/email/account/password/send-code', // 비밀번호 재설정 코드 발송
          '/email/account/password/confirm-code', // 비밀번호 재설정 코드 확인
          '/email/account/password/reset', // 비밀번호 최종 재설정
          // 소셜 로그인 경로가 있다면 추가 (예: '/members/login/social')
        ];

        // 현재 요청 경로가 인증이 필요 없는 경로인지 확인
        bool isPublicPath =
            publicPaths.any((publicPath) => path.endsWith(publicPath));

        // /members/reissue 경로는 쿠키의 refreshToken을 사용하므로 Authorization 헤더 불필요
        if (path.endsWith('/members/reissue')) {
          print("토큰 헤더 추가 안함 (토큰 재발급 경로): ${options.path}");
        } else if (!isPublicPath) {
          final accessToken = await secureStorage.read(key: "accessToken");
          if (accessToken != null) {
            options.headers["Authorization"] = "Bearer $accessToken";
            print("토큰 헤더 추가됨: ${options.path}");
          }
        } else {
          print("토큰 헤더 추가 안함 (공개 경로): ${options.path}");
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // /members/reissue 요청 자체에서 401이 발생한 경우는 재시도 로직을 타면 안됨 (무한 루프 방지)
          // 또한, 이미 재발급 중인 경우에도 추가 재발급 시도를 막습니다.
          if (e.requestOptions.path.endsWith('/members/reissue') ||
              _isRefreshing) {
            if (_isRefreshing &&
                !e.requestOptions.path.endsWith('/members/reissue')) {
              // 재발급이 이미 진행 중일 때 들어온 다른 요청이라면, 해당 요청은 잠시 대기 후 재시도할 수 있도록 처리하거나,
              // 혹은 지금처럼 즉시 에러를 전파할 수 있습니다. 여기서는 간단히 에러 전파.
              print(
                  "AuthInterceptor: Token refresh already in progress or reissue failed. Failing request: ${e.requestOptions.path}");
            } else if (e.requestOptions.path.endsWith('/members/reissue')) {
              print(
                  "AuthInterceptor: Token refresh attempt failed during reissue itself. Logging out.");
              // reissue 실패 시 AuthNotifier를 통해 로그아웃 처리 등을 고려할 수 있으나,
              // 여기서는 일단 AuthNotifier의 직접적인 logout 호출은 refreshAccessToken 실패 시에만 수행하도록 함.
              // await authNotifier.logout(); // 필요시 주석 해제
            }
            return handler.next(e); // 재발급 중이거나, 재발급 요청 자체가 실패한 경우 원래 에러 전파
          }

          _isRefreshing = true;
          try {
            print(
                "AuthInterceptor: Attempting to refresh token for ${e.requestOptions.path}");
            final bool refreshSuccess = await authNotifier.refreshAccessToken();

            if (refreshSuccess) {
              final newAccessToken =
                  await secureStorage.read(key: "accessToken");
              if (newAccessToken != null) {
                e.requestOptions.headers["Authorization"] =
                    "Bearer $newAccessToken";
                print(
                    "AuthInterceptor: Token refreshed. Retrying original request: ${e.requestOptions.path}");
                // dio.fetch를 사용하여 새 요청 생성 및 전송
                final response = await dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } else {
                print(
                    "AuthInterceptor: Token refresh reported success, but no new token found in storage.");
                // 이 경우, AuthNotifier.refreshAccessToken() 내부에서 로그아웃 처리가 되었을 것으로 기대합니다.
                // 만약 AuthNotifier에서 로그아웃 처리를 보장하지 않는다면 여기서 명시적 로그아웃 필요.
                // await authNotifier.logout();
              }
            } else {
              print(
                  "AuthInterceptor: Token refresh failed for ${e.requestOptions.path}. User might have been logged out.");
              // AuthNotifier.refreshAccessToken() 내부에서 이미 logout 처리했을 수 있음
            }
          } catch (refreshProcessError) {
            print(
                "AuthInterceptor: Exception during token refresh process: $refreshProcessError");
            // await authNotifier.logout(); // 예외 발생 시 로그아웃 처리
          } finally {
            _isRefreshing = false;
          }
        }
        return handler.next(e);
      },
    ),
  );
}
