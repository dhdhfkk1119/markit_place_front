import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:markit_place_front/_core/dtos/api_response_dto.dart';
import 'package:markit_place_front/_core/dtos/error_dto.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/members/dtos/login_response.dto.dart'; // For SessionUser

/// 소셜 로그인 관련 API 요청을 처리하는 리포지토리입니다.
///
/// 현재 네이버 소셜 로그인을 지원하며, 추후 다른 소셜 로그인 플랫폼 확장이 가능합니다.
class SocialLoginRepository {
  final Dio _dio = dio; // 전역 dio 인스턴스 사용

  SocialLoginRepository() {
    if (!_dio.interceptors
        .any((interceptor) => interceptor is LogInterceptor)) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  // --- 네이버 소셜 로그인 기능 (MemberAuthRepository에서 이전 방식과 유사하게 수정) ---
  Future<Map<String, dynamic>?> signInWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      print(
          "[NaverLogin] SDK Result: Status: ${result.status}, AccountID: ${result.account.id}");

      if (result.status == NaverLoginStatus.loggedIn) {
        return await _loginToServerWithNaverToken(result); // 내부 메소드 호출 변경
      } else {
        print(
            "[NaverLogin] Naver login attempt was not successful. Status: ${result.status}, Message: ${result.errorMessage}");
        if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
          // Repository에서는 Exception을 발생시키거나, null을 반환하여 Notifier에서 처리하도록 유도
          throw Exception("네이버 로그인 실패: ${result.errorMessage}");
        }
        return null; // 사용자가 취소했거나 SDK 레벨에서 로그인 실패 시 null 반환
      }
    } catch (e) {
      print("[NaverLogin] signInWithNaver Error: $e");
      // extractErrorMessage 유틸리티 사용
      throw Exception("네이버 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  // 내부 헬퍼 메소드 (MemberAuthRepository의 _loginToServerWithNaverToken 방식과 유사)
  Future<Map<String, dynamic>?> _loginToServerWithNaverToken(
      NaverLoginResult naverResult) async {
    // 파라미터 타입 NaverLoginResult로 변경
    final requestData = {
      "provider": "NAVER",
      "providerId": naverResult.account.id, // naverResult.account 사용
      "email": naverResult.account.email, // naverResult.account 사용
    };

    try {
      print(
          "[NaverLogin] Attempting to login to our server with Naver data: ${json.encode(requestData)}");
      final dioResponse = await _dio.post(
        "/members/login/social",
        data: requestData,
      );

      final String? token = dioResponse.headers.value('Authorization');
      final apiResponse = ApiResponseDto<LoginResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: LoginResponseDataDto.fromJson,
      );

      if (token != null &&
          token.isNotEmpty &&
          apiResponse.success &&
          apiResponse.response != null) {
        final sessionUser = apiResponse.response!.toSessionUser();
        print(
            "[NaverLogin] Our server login success! User: ${sessionUser.loginId}, Token (start): ${token.substring(0, token.length > 10 ? 10 : token.length)}...");
        return {
          'sessionUser': sessionUser,
          'token': token.replaceFirst('Bearer ', ''),
        };
      } else if (!apiResponse.success && apiResponse.error != null) {
        print(
            "[NaverLogin] Our server login failed: ${apiResponse.error!.message}");
        throw Exception(apiResponse.error!.message ?? '네이버 소셜 로그인 처리 중 서버 오류');
      } else if (token == null || token.isEmpty) {
        print(
            "[NaverLogin] Our server login failed: Token missing in response");
        throw Exception('네이버 소셜 로그인 응답에 토큰이 없습니다.');
      } else {
        print("[NaverLogin] Our server login failed: Unknown reason");
        throw Exception('알 수 없는 이유로 네이버 소셜 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e, '[NaverLogin DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      print("[NaverLogin] _loginToServerWithNaverToken Error: $e");
      throw Exception("네이버 정보로 서버 로그인 중 오류: ${extractErrorMessage(e)}");
    }
  }

  /// DioException 발생 시 에러 메시지를 파싱하고 로깅하는 내부 헬퍼 메소드.
  String _handleDioError(DioException e, String logPrefix) {
    String finalErrorMessage;
    ErrorDto? parsedErrorDto;

    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final responseData = e.response!.data as Map<String, dynamic>;
      if (responseData.containsKey('error') &&
          responseData['error'] != null &&
          responseData['error'] is Map<String, dynamic>) {
        try {
          parsedErrorDto =
              ErrorDto.fromJson(responseData['error'] as Map<String, dynamic>);
        } catch (parseError) {
          print('$logPrefix - Failed to parse ErrorDto: $parseError');
        }
      }
    }

    if (parsedErrorDto?.message != null &&
        parsedErrorDto!.message!.isNotEmpty) {
      finalErrorMessage = parsedErrorDto.message!;
    } else {
      finalErrorMessage =
          extractErrorMessage(e); // _core/utils/error_utils.dart의 함수
    }
    print(
        '$logPrefix Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
    if (parsedErrorDto != null) {
      print(
          '$logPrefix Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
    }
    return finalErrorMessage;
  }
}

/// {@template common_api_error_handling}
/// **에러 처리 참고:**
/// 이 메소드는 API 요청 중 발생하는 `DioException`을 내부적으로 처리하려고 시도합니다.
/// `DioException.response.data`에 `error` 필드가 포함되어 있고, 이 필드가 `ErrorDto` 형식에
/// 부합하는 경우, 해당 `ErrorDto.message`를 우선적으로 사용합니다.
/// 그렇지 않은 경우 `extractErrorMessage(e)` 유틸리티 함수를 통해 일반적인 Dio 에러 메시지를 추출합니다.
/// 최종적으로 처리된 에러 메시지를 포함하는 `Exception`을 발생시킵니다.
/// 일반적인 `Exception`의 경우에도 해당 메시지를 담아 throw 합니다.
/// {@endtemplate}
