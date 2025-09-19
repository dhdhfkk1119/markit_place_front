// D:/workspace-flutter/markit_place_front/lib/domain/social_login/social_login_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../members/models/session_user.dart';
import '../members/providers/member_auth_provider.dart';
import '../members/providers/profile_provider.dart';
import './social_login_repository.dart'; // Repository import
import '../../_core/utils/error_utils.dart';

// Provider 정의를 이곳으로 이동
final socialLoginRepositoryProvider = Provider<SocialLoginRepository>((ref) {
  return SocialLoginRepository();
});

class SocialLoginNotifier extends Notifier<void> {
  late SocialLoginRepository _socialLoginRepository;
  late AuthNotifier _authNotifier;
  late ProfileNotifier _profileNotifier;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void build() {
    _socialLoginRepository = ref
        .watch(socialLoginRepositoryProvider); // 이제 이 파일 내에 Provider가 정의되어 있음
    _authNotifier = ref.watch(authNotifierProvider.notifier);
    _profileNotifier = ref.watch(profileNotifierProvider.notifier);
  }

  Future<void> signInWithNaver() async {
    _authNotifier.setLoading();
    try {
      final socialLoginResult = await _socialLoginRepository.signInWithNaver();
      if (socialLoginResult != null) {
        final SessionUser? serverUser =
            socialLoginResult['sessionUser'] as SessionUser?;
        final String? token = socialLoginResult['token'] as String?;

        if (serverUser != null && token != null && token.isNotEmpty) {
          await _authNotifier.storeSessionUser(serverUser, token);
          _authNotifier.updateUserAndAuthStatus(
              serverUser, AuthStatus.authenticated, LoginType.social);
          print("[SocialLoginNotifier] 네이버 소셜 로그인 성공: ${serverUser.loginId}");
          await _profileNotifier.fetchMyProfileAndUpdateAuthNotifier(
              showLoading: false);
        } else {
          throw Exception("네이버 소셜 로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
        }
      } else {
        _authNotifier.updateUserAndAuthStatus(
            null, AuthStatus.unauthenticated, LoginType.none);
        print("[SocialLoginNotifier] 네이버 소셜 로그인이 완료되지 않았습니다 (사용자 취소 등).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("네이버 로그인 실패: $errorMessage");
      print("[SocialLoginNotifier] 네이버 소셜 로그인 실패: $errorMessage");
    }
  }

  Future<void> signInWithGoogle() async {
    _authNotifier.setLoading();
    try {
      final Map<String, dynamic>? googleLoginData =
          await _socialLoginRepository.signInWithGoogleAndGetAccount();

      if (googleLoginData != null) {
        final GoogleSignInAccount? googleUserAccount =
            googleLoginData['googleUserAccount'] as GoogleSignInAccount?;
        final SessionUser? serverUser =
            googleLoginData['sessionUser'] as SessionUser?;
        final String? token = googleLoginData['token'] as String?;

        if (serverUser != null &&
            token != null &&
            token.isNotEmpty &&
            googleUserAccount != null) {
          await _authNotifier.storeSessionUser(serverUser, token);
          _authNotifier.updateUserAndAuthStatus(
              serverUser, AuthStatus.authenticated, LoginType.social);
          print("[SocialLoginNotifier] 구글 소셜 로그인 성공: ${serverUser.loginId}");

          bool needsServerUpdate = false;
          String? googlePhotoUrl = googleUserAccount.photoUrl;
          String? googleDisplayName = googleUserAccount.displayName;

          if (googleDisplayName != null &&
              serverUser.name != googleDisplayName) {
            needsServerUpdate = true;
          }
          if (googlePhotoUrl != null) {
            needsServerUpdate = true;
          }

          if (needsServerUpdate) {
            print(
                "[SocialLoginNotifier] Google 프로필 정보로 서버 프로필 업데이트 시도: Name: $googleDisplayName, PhotoURL: $googlePhotoUrl");
            await _profileNotifier.updateProfile(
              name: googleDisplayName,
              newProfileImageBase64: googlePhotoUrl,
            );
          } else {
            print(
                "[SocialLoginNotifier] Google 프로필 정보가 이미 최신이거나, Google 정보가 없어 서버 업데이트를 건너뜁니다.");
            await _profileNotifier.fetchMyProfileAndUpdateAuthNotifier(
                showLoading: false);
          }
        } else {
          throw Exception("구글 소셜 로그인 처리 중 필요한 데이터(유저/토큰/구글계정정보)가 누락되었습니다.");
        }
      } else {
        _authNotifier.updateUserAndAuthStatus(
            null, AuthStatus.unauthenticated, LoginType.none);
        print(
            "[SocialLoginNotifier] 구글 소셜 로그인이 완료되지 않았습니다 (사용자 취소 또는 SDK 오류 등).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("구글 로그인 실패: $errorMessage");
      print("[SocialLoginNotifier] 구글 소셜 로그인 실패: $errorMessage");
    }
  }

  Future<void> trySignInWithDifferentGoogleAccount() async {
    _authNotifier.setLoading();
    try {
      await _socialLoginRepository.signOutFromGoogle();
      await signInWithGoogle();
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("구글 계정 전환 중 오류: $errorMessage");
      print("[SocialLoginNotifier] 구글 계정 전환 중 오류: $errorMessage");
    }
  }

  Future<void> signOutFromGoogleSdk() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        print("[SocialLoginNotifier] Signed out from Google SDK.");
      }
    } catch (e) {
      print("[SocialLoginNotifier] Error during Google SDK signOut: $e");
    }
  }
}

final socialLoginNotifierProvider =
    NotifierProvider<SocialLoginNotifier, void>(() {
  return SocialLoginNotifier();
});
