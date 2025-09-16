import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// todo - 개인 로컬 컴퓨터 주소로 수정하세요
/// 임시 로컬 서버 - http://192.168.0.128:8080/api
/// 임시 클라우드 서버 - https://port-0-market-place-server-m9sgwbay02179a7c.sel4.cloudtype.app/api
const baseUrl =
    "https://port-0-market-place-server-m9sgwbay02179a7c.sel4.cloudtype.app/api";

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
          options.headers["Authorization"] =
              "Bearer $accessToken"; // "Bearer " 추가
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ),
  );
}
