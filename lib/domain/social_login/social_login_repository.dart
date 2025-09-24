// D:/workspace-flutter/markit_place_front/lib/domain/social_login/social_login_repository.dart
import 'dart:convert';
import 'dart:typed_data'; // For Uint8List if needed, though List<int> from Dio is fine for base64Encode

import 'package:dio/dio.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../../_core/dtos/api_response_dto.dart';
import '../../_core/dtos/error_dto.dart';
import '../../_core/utils/error_utils.dart';
import '../../_core/utils/my_http.dart';
import '../members/dtos/login_response.dto.dart';
import '../members/models/session_user.dart';
import 'social_login_request_dto.dart';
import 'social_login_result_dto.dart';

final logger = Logger();

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

  Future<String?> _fetchImageAsBase64(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    try {
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes), // Get raw bytes
      );
      if (response.statusCode == 200 && response.data != null) {
        return base64Encode(response.data!);
      }
      logger.w(
          "[SocialLoginRepo] Failed to fetch image from $imageUrl. Status: ${response.statusCode}");
      return null;
    } catch (e, stackTrace) {
      logger.e(
          "[SocialLoginRepo] Error fetching or encoding image from $imageUrl",
          e,
          stackTrace);
      return null;
    }
  }

  // --- 네이버 소셜 로그인 ---
  /// 네이버 로그인을 시도하고, 성공 시 서버 로그인 결과 및 네이버 프로필 정보를 반환합니다.
  Future<SocialLoginResultDto?> signInWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      logger.i(
          "[NaverLogin] SDK Account Info: id=${result.account.id}, email=${result.account.email}, name=${result.account.name}, nickname=${result.account.nickname}, profileImage=${result.account.profileImage}, birthday=${result.account.birthday}, birthyear=${result.account.birthyear}, gender=${result.account.gender}, age=${result.account.age}, mobile=${result.account.mobile}");

      if (result.status == NaverLoginStatus.loggedIn) {
        final requestDto = SocialLoginRequestDto(
          provider: "NAVER",
          providerId: result.account.id,
          email: result.account.email,
        );

        final Map<String, dynamic>? serverLoginResult =
            await _loginToServerWithSocialToken(requestDto);

        if (serverLoginResult != null) {
          final String? naverAccountName =
              result.account.name ?? result.account.nickname;
          final String? naverProfileImageUrl = result.account.profileImage;
          String? naverProfileImageBase64;

          if (naverProfileImageUrl != null && naverProfileImageUrl.isNotEmpty) {
            naverProfileImageBase64 =
                await _fetchImageAsBase64(naverProfileImageUrl);
            if (naverProfileImageBase64 != null) {
              logger.i(
                  "[NaverLogin] Successfully converted Naver profile image URL to Base64.");
            } else {
              logger.w(
                  "[NaverLogin] Failed to convert Naver profile image URL to Base64. URL: $naverProfileImageUrl");
            }
          }

          logger.i(
              "[NaverLogin] Extracted Naver Profile: Name='$naverAccountName', ImageUrl='$naverProfileImageUrl', HasBase64=${naverProfileImageBase64 != null}");

          return SocialLoginResultDto(
            sessionUser: serverLoginResult['sessionUser'] as SessionUser?,
            token: serverLoginResult['token'] as String?,
            socialAccountName: naverAccountName,
            socialProfileImageBase64: naverProfileImageBase64,
          );
        } else {
          logger.w("[NaverLogin] Server login failed after Naver SDK success.");
          return null;
        }
      } else {
        logger.w(
            "[NaverLogin] Naver login not successful. Status: ${result.status}, Message: ${result.errorMessage}");
        if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
          throw Exception("네이버 로그인 실패: ${result.errorMessage}");
        }
        return null; // 사용자 취소 등
      }
    } catch (e, stackTrace) {
      logger.e('[NaverLogin] signInWithNaver Error', e, stackTrace);
      throw Exception("네이버 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  // --- 구글 소셜 로그인 ---
  /// Google 로그인을 시도하고, 성공 시 서버 로그인 결과와 Google 프로필 정보를 반환합니다.
  Future<SocialLoginResultDto?> signInWithGoogleAndGetAccount() async {
    try {
      await signOutFromGoogle();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        logger.w("[GoogleLogin] Google sign-in cancelled by user.");
        return null;
      }
      logger.i(
          "[GoogleLogin] SDK Result: User Email: ${googleUser.email}, ID: ${googleUser.id}, Name: ${googleUser.displayName}, Photo: ${googleUser.photoUrl}");

      final requestDto = SocialLoginRequestDto(
        provider: "GOOGLE",
        providerId: googleUser.id,
        email: googleUser.email,
      );

      final Map<String, dynamic>? serverLoginResult =
          await _loginToServerWithSocialToken(requestDto);

      if (serverLoginResult != null) {
        final String? googleAccountName = googleUser.displayName;
        final String? googleProfileImageUrl = googleUser.photoUrl;
        String? googleProfileImageBase64;

        if (googleProfileImageUrl != null && googleProfileImageUrl.isNotEmpty) {
          googleProfileImageBase64 =
              await _fetchImageAsBase64(googleProfileImageUrl);
          if (googleProfileImageBase64 != null) {
            logger.i(
                "[GoogleLogin] Successfully converted Google profile image URL to Base64.");
          } else {
            logger.w(
                "[GoogleLogin] Failed to convert Google profile image URL to Base64. URL: $googleProfileImageUrl");
          }
        }
        logger.i(
            "[GoogleLogin] Extracted Google Profile: Name='$googleAccountName', ImageUrl='$googleProfileImageUrl', HasBase64=${googleProfileImageBase64 != null}");

        return SocialLoginResultDto(
          sessionUser: serverLoginResult['sessionUser'] as SessionUser?,
          token: serverLoginResult['token'] as String?,
          socialAccountName: googleAccountName,
          socialProfileImageBase64: googleProfileImageBase64,
        );
      } else {
        logger.w("[GoogleLogin] Server login failed after Google SDK success.");
        return null;
      }
    } catch (e, stackTrace) {
      logger.e(
          '[GoogleLogin] signInWithGoogleAndGetAccount Error', e, stackTrace);
      throw Exception("구글 로그인 중 오류 발생: ${extractErrorMessage(e)}");
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        logger.i("[GoogleLoginRepo] Signed out from Google.");
      }
    } catch (e, stackTrace) {
      logger.e(
          "[GoogleLoginRepo] Error signing out from Google: $e", e, stackTrace);
    }
  }

  Future<Map<String, dynamic>?> _loginToServerWithSocialToken(
      SocialLoginRequestDto requestDto) async {
    try {
      logger.i(
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
        logger.i(
            "[SocialLoginRepo] Server login success! User: ${sessionUser.loginId}, Provider: ${requestDto.provider}, ServerProvider: ${sessionUser.provider}");
        return {
          'sessionUser': sessionUser,
          'token': token.replaceFirst('Bearer ', ''),
        };
      } else if (!apiResponse.success && apiResponse.error != null) {
        logger.w(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: ${apiResponse.error!.message}");
        throw Exception(apiResponse.error!.message ??
            '${requestDto.provider} 소셜 로그인 처리 중 서버 오류');
      } else if (token == null || token.isEmpty) {
        logger.w(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: Token missing.");
        throw Exception('${requestDto.provider} 소셜 로그인 응답에 토큰이 없습니다.');
      } else {
        logger.w(
            "[SocialLoginRepo] Server login failed for ${requestDto.provider}: Unknown reason.");
        throw Exception('알 수 없는 이유로 ${requestDto.provider} 소셜 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(
          e, '[SocialLoginRepo DioException - ${requestDto.provider}]');
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      logger.e(
          "[SocialLoginRepo] _loginToServerWithSocialToken (${requestDto.provider}) Error",
          e,
          stackTrace);
      throw Exception(
          "${requestDto.provider} 정보로 서버 로그인 중 오류: ${extractErrorMessage(e)}");
    }
  }

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
        } catch (parseError, stackTrace) {
          logger.e(
              '$logPrefix - Failed to parse ErrorDto', parseError, stackTrace);
        }
      }
    }

    if (parsedErrorDto?.message != null &&
        parsedErrorDto!.message!.isNotEmpty) {
      finalErrorMessage = parsedErrorDto.message!;
    } else {
      finalErrorMessage = extractErrorMessage(e);
    }
    logger.i(
        '$logPrefix Final Message: $finalErrorMessage (Dio Status: ${e.response?.statusCode})');
    if (parsedErrorDto != null) {
      logger.i(
          '$logPrefix Parsed ErrorDto: Code: ${parsedErrorDto.code}, Field: ${parsedErrorDto.field}, Status: ${parsedErrorDto.status}');
    }
    return finalErrorMessage;
  }
}
