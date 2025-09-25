// D:/workspace-flutter/markit_place_front/lib/domain/social_login/social_login_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart'; // Logger 추가

import '../../_core/utils/error_utils.dart';
import '../../domain/profile/profile_provider.dart';
import '../members/dtos/profile_update_request_dto.dart';
import '../members/models/session_user.dart';
import '../members/providers/member_auth_provider.dart';
import './social_login_repository.dart';
import 'social_login_result_dto.dart';

final logger = Logger(); // Logger 인스턴스

final socialLoginRepositoryProvider = Provider<SocialLoginRepository>((ref) {
  return SocialLoginRepository();
});

class SocialLoginNotifier extends Notifier<void> {
  late SocialLoginRepository _socialLoginRepository;
  late AuthNotifier _authNotifier;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void build() {
    _socialLoginRepository = ref.watch(socialLoginRepositoryProvider);
    _authNotifier = ref.watch(authNotifierProvider.notifier);
  }

  Future<void> _fetchProfileAndUpdateAuth() async {
    try {
      final profileRepository = ref.read(ProfileRepositoryProvider);
      final SessionUser? fullUserProfile =
          await profileRepository.getMyProfile();
      if (fullUserProfile != null) {
        await _authNotifier.refreshSessionUser(fullUserProfile);
        logger.i(
            "[SocialLoginNotifier] Profile fetched and session refreshed. User provider: ${fullUserProfile.provider}, Name: ${fullUserProfile.name}, Image URL: ${fullUserProfile.profileImageUrl}, Image Base64: ${fullUserProfile.profileImageBase64 != null ? "Present" : "Absent"}");
      } else {
        logger.w(
            "[SocialLoginNotifier] Fetched profile is null after _fetchProfileAndUpdateAuth.");
      }
    } catch (e, stackTrace) {
      logger.e(
          "[SocialLoginNotifier] Error in _fetchProfileAndUpdateAuth: ${extractErrorMessage(e)}",
          e,
          stackTrace);
    }
  }

  Future<void> _updateServerProfile(
      ProfileUpdateRequestDto dto, String socialProviderName) async {
    if (dto.name == null && dto.profileImage == null) {
      logger.i(
          "[SocialLoginNotifier] No changes in name or profile image for $socialProviderName to update server. Skipping server update, but fetching profile.");
      await _fetchProfileAndUpdateAuth();
      return;
    }

    try {
      logger.i(
          "[SocialLoginNotifier] Attempting to update server profile with $socialProviderName data: ${dto.toJson()}");
      final profileRepository = ref.read(ProfileRepositoryProvider);
      await profileRepository.updateMyProfile(dto);
      logger.i(
          "[SocialLoginNotifier] Server profile update with $socialProviderName data successful.");
    } catch (e, stackTrace) {
      logger.e(
          "[SocialLoginNotifier] Server profile update with $socialProviderName data failed: ${extractErrorMessage(e)}",
          e,
          stackTrace);
    } finally {
      await _fetchProfileAndUpdateAuth();
    }
  }

  Future<void> _processSocialLoginResult({
    required SessionUser serverUser,
    required String? token,
    required String? socialAccountName,
    required String? socialProfileImageBase64,
    required String providerName,
  }) async {
    SessionUser userForAppAuth = serverUser;
    ProfileUpdateRequestDto dtoForServerUpdate = ProfileUpdateRequestDto();

    if (socialAccountName != null && socialAccountName.isNotEmpty) {
      userForAppAuth = userForAppAuth.copyWith(name: socialAccountName);
      dtoForServerUpdate = dtoForServerUpdate.copyWith(name: socialAccountName);
    }

    if (socialProfileImageBase64 != null &&
        socialProfileImageBase64.isNotEmpty) {
      userForAppAuth = userForAppAuth.copyWith(
          profileImageBase64: socialProfileImageBase64,
          allowNullProfileImageUrl: true,
          profileImageUrl: null);
      dtoForServerUpdate =
          dtoForServerUpdate.copyWith(profileImage: socialProfileImageBase64);
    }

    await _authNotifier.updateUserAndAuthStatus(
        userForAppAuth, AuthStatus.authenticated, LoginType.social,
        newToken: token);
    logger.i(
        "[SocialLoginNotifier] $providerName sign-in successful for app auth. User: ${userForAppAuth.loginId}, Name: ${userForAppAuth.name}, ImageBase64: ${userForAppAuth.profileImageBase64 != null ? "Present" : "Absent"}, Provider: ${userForAppAuth.provider}");

    await _updateServerProfile(dtoForServerUpdate, providerName);
  }

  Future<void> signInWithNaver() async {
    _authNotifier.setLoading();
    try {
      final socialLoginResult = await _socialLoginRepository.signInWithNaver();
      if (socialLoginResult != null) {
        if (socialLoginResult.sessionUser != null &&
            socialLoginResult.token != null &&
            socialLoginResult.token!.isNotEmpty) {
          await _processSocialLoginResult(
            serverUser: socialLoginResult.sessionUser!,
            token: socialLoginResult.token,
            socialAccountName: socialLoginResult.socialAccountName,
            socialProfileImageBase64:
                socialLoginResult.socialProfileImageBase64,
            providerName: "Naver",
          );
        } else {
          throw Exception("네이버 소셜 로그인 처리 중 서버 응답 데이터(유저/토큰)가 누락되었습니다.");
        }
      } else {
        await _authNotifier.updateUserAndAuthStatus(
            null, AuthStatus.unauthenticated, LoginType.none);
        logger.w("[SocialLoginNotifier] 네이버 소셜 로그인이 완료되지 않았습니다 (사용자 취소 등).");
      }
    } catch (e, stackTrace) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("네이버 로그인 실패: $errorMessage");
      logger.e(
          "[SocialLoginNotifier] 네이버 소셜 로그인 실패: $errorMessage", e, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    _authNotifier.setLoading();
    try {
      await _socialLoginRepository.signOutFromGoogle();

      final socialLoginResult =
          await _socialLoginRepository.signInWithGoogleAndGetAccount();

      if (socialLoginResult != null) {
        if (socialLoginResult.sessionUser != null &&
            socialLoginResult.token != null &&
            socialLoginResult.token!.isNotEmpty) {
          await _processSocialLoginResult(
            serverUser: socialLoginResult.sessionUser!,
            token: socialLoginResult.token,
            socialAccountName: socialLoginResult.socialAccountName,
            socialProfileImageBase64:
                socialLoginResult.socialProfileImageBase64,
            providerName: "Google",
          );
        } else {
          throw Exception("구글 소셜 로그인 처리 중 필요한 데이터(유저/토큰)가 누락되었습니다.");
        }
      } else {
        await _authNotifier.updateUserAndAuthStatus(
            null, AuthStatus.unauthenticated, LoginType.none);
        logger.w(
            "[SocialLoginNotifier] 구글 소셜 로그인이 완료되지 않았습니다 (사용자 취소 또는 SDK 오류 등).");
      }
    } catch (e, stackTrace) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("구글 로그인 실패: $errorMessage");
      logger.e(
          "[SocialLoginNotifier] 구글 소셜 로그인 실패: $errorMessage", e, stackTrace);
    }
  }

  Future<void> trySignInWithDifferentGoogleAccount() async {
    _authNotifier.setLoading();
    try {
      await _socialLoginRepository.signOutFromGoogle();
      await signInWithGoogle();
    } catch (e, stackTrace) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("구글 계정 전환 중 오류: $errorMessage");
      logger.e(
          "[SocialLoginNotifier] 구글 계정 전환 중 오류: $errorMessage", e, stackTrace);
    }
  }

  Future<void> signOutFromGoogleSdk() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        logger.i("[SocialLoginNotifier] Signed out from Google SDK.");
      }
    } catch (e, stackTrace) {
      logger.e("[SocialLoginNotifier] Error during Google SDK signOut: $e", e,
          stackTrace);
    }
  }
}

final socialLoginNotifierProvider =
    NotifierProvider<SocialLoginNotifier, void>(() {
  return SocialLoginNotifier();
});
