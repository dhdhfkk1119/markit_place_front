import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// todo - 개인 로컬 컴퓨터 주소로 수정하세요
const baseUrl = "http://115.22.177.29:8080/api";

final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl, // 내 IP 입력
    contentType: "application/json; charset=utf-8",
    // 200 이 아니면 무조건 오류로 본다. 아래 내용을 필수로 넣어야 함
    validateStatus: (status) => true, // 200 이 아니어도 예외 발생안하게 설정 주의!!
  ),
);

const secureStorage = FlutterSecureStorage();

void setupInterceptors() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 모든 요청에 저장된 토큰을 자동으로 추가
        final accessToken = await secureStorage.read(key: "accessToken");
        if (accessToken != null) {
          options.headers["Authorization"] = accessToken;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        // 이 부분이 바로 토큰을 저장하는 핵심 로직입니다!
        // 서버 응답 헤더에서 'Authorization' 값을 가져와서 저장.
        final accessToken = response.headers.value("Authorization");
        if (accessToken != null) {
          await secureStorage.write(key: "accessToken", value: accessToken);
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // 오류 처리 로직 (예: 401 Unauthorized 시 로그아웃)
        return handler.next(e);
      },
    ),
  );
}
