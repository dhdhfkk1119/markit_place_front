import 'dart:async';

import 'package:dio/dio.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

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

  // 네이버 소셜 로그인용
  Future<void> signInWithNaver() async {
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    Logger().i(result);

    if (result.status == NaverLoginStatus.loggedIn) {
      final NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
      final String naverAccessToken = res.accessToken;
      await _loginToServerWithNaverToken(result, naverAccessToken);
    }
  }

  // 네이버 로그인 성공시 우리 서버와 통신하는 코드
  Future<void> _loginToServerWithNaverToken(
      NaverLoginResult result, String token) async {
    try {
      final requestData = {
        "provider": "NAVER",
        "providerId": result.account.id,
        "email": result.account.email
      };

      final response = await dio.post(
        "/members/login/social",
        data: json.encode(requestData),
      );
      print("우리 서버로부터 로그인 성공! JWT: ${response.data}");
    } catch (e) {
      print("우리 서버 로그인 실패: $e");
    }
  }
}
