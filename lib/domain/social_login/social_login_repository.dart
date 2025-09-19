import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:markit_place_front/_core/dtos/api_response_dto.dart';
import 'package:markit_place_front/_core/dtos/error_dto.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/domain/members/dtos/login_response.dto.dart'; // SessionUser 생성을 위해 유지
import 'social_login_request_dto.dart';

/// 소셜 로그인 관련 API 요청을 처리하는 리포지토리입니다.
class SocialLoginRepository {
  final Dio _dio = dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn 인스턴스 추가

  SocialLoginRepository() {
    if (!_dio.interceptors
        .any((interceptor) => interceptor is LogInterceptor)) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  // --- 네이버 소셜 로그인 기능 ---
  Future<Map<String, dynamic>?> signInWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      print(
          "[NaverLogin] SDK Result: Status: ${result.status}, AccountID: ${result.account.id}");

      if (result.status == NaverLoginStatus.loggedIn) {
        // SocialLoginRequestDto 사용 및 공통 헬퍼 메소드 호출로 변경
        final requestDto = SocialLoginRequestDto(
          provider: "NAVER",
          providerId: result.account.id,
          email: result.account.email,
        );
        return await _loginToServerWithSocialToken(requestDto);
      } else {
        print(
            "[NaverLogin] Naver login attempt was not successful. Status: ${result.status}, Message: ${result.errorMessage}");
        if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
          throw Exception("네이버 로그인 실패: ${result.errorMessage}");
        }
        return null;
      }
    } catch (e) {
      print("[NaverLogin] signInWithNaver Error: $e");
      throw Exception("네이버 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  // --- 구글 소셜 로그인 기능 (신규 추가) ---
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        print("[GoogleLogin] Google sign in cancelled by user.");
        return null;
      }
      print(
          "[GoogleLogin] SDK Result: User Email: ${googleUser.email}, User ID: ${googleUser.id}");

      // SocialLoginRequestDto 생성
      final requestDto = SocialLoginRequestDto(
        provider: "GOOGLE",
        providerId: googleUser.id,
        email: googleUser.email,
      );
      // 공통 헬퍼 메소드 호출
      return await _loginToServerWithSocialToken(requestDto);
    } catch (e) {
      print("[GoogleLogin] signInWithGoogle Error: $e");
      // 필요시 GoogleSignInAuthentication 토큰 정보 (idToken, accessToken) 사용 가능
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      throw Exception("구글 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  /// 다음 로그인 시 사용자가 다른 계정을 선택할 수 있도록 Google에서 로그아웃합니다.
  Future<void> signOutFromGoogle() async {
    try {
      // signOut만으로도 계정 선택기가 다시 표시될 수 있습니다.
      // 그렇지 않다면, disconnect()가 더 강력하지만 권한도 철회합니다.
      // 일단 signOut으로 시작합니다.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("[GoogleLoginRepo] Google에서 로그아웃했습니다.");
      }
    } catch (e) {
      print("[GoogleLoginRepo] Google 로그아웃 중 오류 발생: $e");
      // 필요에 따라 오류를 다시 발생시키거나 처리할 수 있지만,
      // 이 흐름의 주 목적은 새로운 로그인 시도를 허용하는 것이므로 오류를 출력하는 것만으로도 충분할 수 있습니다.
    }
  }

  // --- 소셜 토큰으로 서버에 로그인하는 공통 내부 헬퍼 메소드 ---
  // (기존 _loginToServerWithNaverToken을 일반화하여 SocialLoginRequestDto 사용)
  Future<Map<String, dynamic>?> _loginToServerWithSocialToken(
      SocialLoginRequestDto requestDto) async {
    // 파라미터 변경
    try {
      print(
          "[SocialLoginRepo] Attempting to login to our server with ${requestDto.provider} data: ${json.encode(requestDto.toJson())}");
      final dioResponse = await _dio.post(
        "/members/login/social", // 소셜 로그인 공통 엔드포인트
        data: requestDto.toJson(), // DTO의 toJson 메소드 사용
      );

      final String? token = dioResponse.headers.value('Authorization');
      // LoginResponseDataDto는 SessionUser 생성을 위해 그대로 사용 (서버 응답 구조가 동일하다고 가정)
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
            "[SocialLoginRepo] Server login success! User: ${sessionUser.loginId}, Provider: ${requestDto.provider}, Token (start): ${token.substring(0, token.length > 10 ? 10 : token.length)}...");
        return {
          'sessionUser': sessionUser,
          'token': token.replaceFirst('Bearer ', ''),
        };
      } else if (!apiResponse.success && apiResponse.error != null) {
        print(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: ${apiResponse.error!.message}");
        throw Exception(apiResponse.error!.message ??
            '${requestDto.provider} 소셜 로그인 처리 중 서버 오류');
      } else if (token == null || token.isEmpty) {
        print(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: Token missing in response");
        throw Exception('${requestDto.provider} 소셜 로그인 응답에 토큰이 없습니다.');
      } else {
        print(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: Unknown reason");
        throw Exception('알 수 없는 이유로 ${requestDto.provider} 소셜 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[SocialLoginRepo DioException - ${requestDto.provider}]');
      throw Exception(errorMessage);
    } catch (e) {
      print(
          "[SocialLoginRepo] _loginToServerWithSocialToken (${requestDto.provider}) Error: $e");
      throw Exception(
          "${requestDto.provider} 정보로 서버 로그인 중 오류: ${extractErrorMessage(e)}");
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
