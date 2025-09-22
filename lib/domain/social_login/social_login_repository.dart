// D:/workspace-flutter/markit_place_front/lib/domain/social_login/social_login_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../_core/dtos/api_response_dto.dart';
import '../../_core/dtos/error_dto.dart';
import '../../_core/utils/error_utils.dart';
import '../../_core/utils/my_http.dart';
import '../members/dtos/login_response.dto.dart';
import '../../_core/sessions/session_user.dart';
import 'social_login_request_dto.dart';

/// 소셜 로그인 관련 API 요청을 처리하는 리포지토리입니다.
class SocialLoginRepository {
  final Dio _dio = dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  SocialLoginRepository() {
    // Dio 인터셉터 설정 (중복 방지)
    if (!_dio.interceptors
        .any((interceptor) => interceptor is LogInterceptor)) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  // --- 네이버 소셜 로그인 ---
  /// 네이버 로그인을 시도하고, 성공 시 서버 로그인 결과 (SessionUser, token)를 반환합니다.
  Future<Map<String, dynamic>?> signInWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      print(
          "[NaverLogin] SDK Result: Status: ${result.status}, AccountID: ${result.account.id}");

      if (result.status == NaverLoginStatus.loggedIn) {
        final requestDto = SocialLoginRequestDto(
          provider: "NAVER",
          providerId: result.account.id,
          email: result.account.email,
        );
        return await _loginToServerWithSocialToken(requestDto);
      } else {
        print(
            "[NaverLogin] Naver login not successful. Status: ${result.status}, Message: ${result.errorMessage}");
        if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
          throw Exception("네이버 로그인 실패: ${result.errorMessage}");
        }
        return null; // 사용자 취소 등
      }
    } catch (e) {
      print("[NaverLogin] signInWithNaver Error: $e");
      throw Exception("네이버 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  // --- 구글 소셜 로그인 ---
  /// Google 로그인을 시도하고, 성공 시 서버 로그인 결과와 GoogleSignInAccount 객체를 함께 반환합니다.
  /// 반환 Map 에는 'sessionUser' (SessionUser), 'token' (String), 'googleUserAccount' (GoogleSignInAccount)가 포함됩니다.
  Future<Map<String, dynamic>?> signInWithGoogleAndGetAccount() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("[GoogleLogin] Google sign-in cancelled by user.");
        return null; // 사용자가 로그인 취소
      }
      print(
          "[GoogleLogin] SDK Result: User Email: ${googleUser.email}, ID: ${googleUser.id}, Name: ${googleUser.displayName}, Photo: ${googleUser.photoUrl}");

      final requestDto = SocialLoginRequestDto(
        provider: "GOOGLE",
        providerId: googleUser.id,
        email: googleUser.email,
      );

      final Map<String, dynamic>? serverLoginResult =
          await _loginToServerWithSocialToken(requestDto);

      if (serverLoginResult != null) {
        // 서버 로그인 성공 시, 결과에 GoogleSignInAccount 객체를 추가하여 반환
        return {
          'sessionUser': serverLoginResult['sessionUser'] as SessionUser?,
          'token': serverLoginResult['token'] as String?,
          'googleUserAccount': googleUser, // GoogleSignInAccount 객체
        };
      } else {
        // 서버 로그인 실패 (예: _loginToServerWithSocialToken에서 null 반환 또는 예외 발생 후 catch)
        print("[GoogleLogin] Server login failed after Google SDK success.");
        return null;
      }
    } catch (e) {
      print("[GoogleLogin] signInWithGoogleAndGetAccount Error: $e");
      throw Exception("구글 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  /// Google 계정에서 로그아웃합니다. (다음 로그인 시 계정 선택 가능하도록)
  Future<void> signOutFromGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("[GoogleLoginRepo] Signed out from Google.");
      }
    } catch (e) {
      print("[GoogleLoginRepo] Error signing out from Google: $e");
    }
  }

  // --- 공통 내부 헬퍼: 소셜 정보로 서버에 로그인 ---
  /// 소셜 로그인 정보(SocialLoginRequestDto)를 사용하여 서버에 로그인을 요청합니다.
  /// 성공 시 'sessionUser' (SessionUser)와 'token' (String)을 포함한 Map을 반환합니다.
  Future<Map<String, dynamic>?> _loginToServerWithSocialToken(
      SocialLoginRequestDto requestDto) async {
    try {
      print(
          "[SocialLoginRepo] Attempting server login with ${requestDto.provider} data: ${json.encode(requestDto.toJson())}");
      final dioResponse = await _dio.post(
        "/members/login/social",
        data: requestDto.toJson(),
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
            "[SocialLoginRepo] Server login success! User: ${sessionUser.loginId}, Provider: ${requestDto.provider}");
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
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: Token missing.");
        throw Exception('${requestDto.provider} 소셜 로그인 응답에 토큰이 없습니다.');
      } else {
        print(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: Unknown reason.");
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
      finalErrorMessage = extractErrorMessage(e);
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
