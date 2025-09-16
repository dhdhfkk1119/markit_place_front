import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Import AuthNotifier
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';

/// todo - 개인 로컬 컴퓨터 주소로 수정하세요
/// 팀장 서버 주소 - http://192.168.0.128:8080/api
/// 자기 서버 주소 - http://10.0.2.2:8080/api
/// 임시 클라우드 서버 - https://port-0-market-place-server-m9sgwbay02179a7c.sel4.cloudtype.app/api
const baseUrl =
    "https://port-0-market-place-server-m9sgwbay02179a7c.sel4.cloudtype.app/api";

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
        final accessToken = await secureStorage.read(key: "accessToken");
        if (accessToken != null) {
          options.headers["Authorization"] = "Bearer $accessToken";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          if (!_isRefreshing) {
            _isRefreshing = true;
            try {
              print(
                  "AuthInterceptor: Attempting to refresh token for ${e.requestOptions.path}");
              final bool refreshSuccess =
                  await authNotifier.refreshAccessToken();

              if (refreshSuccess) {
                // Token refreshed successfully, retry the original request
                final newAccessToken =
                    await secureStorage.read(key: "accessToken");
                if (newAccessToken != null) {
                  e.requestOptions.headers["Authorization"] =
                      "Bearer $newAccessToken";
                  print(
                      "AuthInterceptor: Token refreshed. Retrying original request: ${e.requestOptions.path}");
                  // Retry the request with the new token
                  // dio.fetch creates a new request from RequestOptions
                  final response = await dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                } else {
                  print(
                      "AuthInterceptor: Token refresh reported success, but no new token found in storage.");
                  // Fall through to propagate the original error
                }
              } else {
                // Refresh failed, user should have been logged out by AuthNotifier.
                print(
                    "AuthInterceptor: Token refresh failed for ${e.requestOptions.path}. Propagating original error.");
                // Fall through to propagate the original error
              }
            } catch (refreshProcessError) {
              print(
                  "AuthInterceptor: Exception during token refresh process: $refreshProcessError");
              // Fall through to propagate the original error
            } finally {
              _isRefreshing = false;
            }
          } else {
            // Refresh already in progress.
            // For simplicity, we let this subsequent request fail.
            // A more sophisticated solution might queue requests or use a shared Completer.
            print(
                "AuthInterceptor: Token refresh already in progress. Failing request: ${e.requestOptions.path}");
            // Fall through to propagate the original error
          }
        }
        // For non-401 errors or if refresh logic doesn't resolve/retry, propagate the original error.
        return handler.next(e);
      },
    ),
  );
}
