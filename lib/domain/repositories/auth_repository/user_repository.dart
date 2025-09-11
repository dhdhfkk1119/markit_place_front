import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../_core/utils/my_http.dart';

class UserRepository {
  Future<Map<String, dynamic>> join(String loginId, String password) async {
    final requestBody = {
      "loginId": loginId,
      "password": password,
    };
    Response response = await dio.post("/members/register", data: requestBody);

    final responseBody = response.data;
    Logger().d(responseBody);

    return responseBody;
  }

  // 자동 로그인 유무를 체크 해주기 위해서 Response 를 반환
  Future<Response> login(String loginId, String password) async {
    final requestBody = {
      "loginId": loginId,
      "password": password,
    };
    Response response = await dio.post("/members/login", data: requestBody);

    Logger().d(response.data); // 응답 데이터 로깅
    return response; // Response 객체 전체 반환
  }

  Future<Map<String, dynamic>> autoLogin(String accessToken) async {
    Response response = await dio.post(
      "/api/members/reissue",
      options: Options(
        headers: {"Authorization": accessToken},
      ),
    );

    Map<String, dynamic> responseBody = response.data;
    Logger().e(responseBody);
    return responseBody;
  }
}
