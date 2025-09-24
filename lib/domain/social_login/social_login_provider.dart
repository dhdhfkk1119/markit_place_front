// D:/workspace-flutter/markit_place_front/lib/domain/social_login/social_login_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../_core/utils/error_utils.dart';
import '../../domain/profile/profile_provider.dart'; // ProfileRepositoryProvider를 위해 추가
import '../members/dtos/profile_update_request_dto.dart'; // ProfileUpdateRequestDto 사용을 위해 추가
import '../members/models/session_user.dart';
import '../members/providers/member_auth_provider.dart';
import './social_login_repository.dart'; // Repository import

// Provider 정의를 이곳으로 이동
final socialLoginRepositoryProvider = Provider<SocialLoginRepository>((ref) {
  return SocialLoginRepository();
});

class SocialLoginNotifier extends Notifier<void> {
  late SocialLoginRepository _socialLoginRepository;
  late AuthNotifier _authNotifier;

  // late ProfileNotifier _profileNotifier; // 삭제
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void build() {
    _socialLoginRepository = ref.watch(socialLoginRepositoryProvider);
    _authNotifier = ref.watch(authNotifierProvider.notifier);
    // _profileNotifier = ref.watch(profileNotifierProvider.notifier); // 삭제
  }

  Future<void> _fetchProfileAndUpdateAuth() async {
    try {
      final profileRepository = ref.read(ProfileRepositoryProvider);
      final SessionUser? fullUserProfile =
          await profileRepository.getMyProfile();
      if (fullUserProfile != null) {
        await _authNotifier.refreshSessionUser(fullUserProfile);
        print(
            "[SocialLoginNotifier] Profile fetched and session refreshed after social login.");
      }
    } catch (e) {
      print(
          "[SocialLoginNotifier] Error fetching profile after social login: ${extractErrorMessage(e)}");
      // 에러를 authNotifier에 전달할 수도 있습니다.
      // _authNotifier.setErrorOnAuthenticated("소셜 로그인 후 프로필 조회 실패: ${extractErrorMessage(e)}");
    }
  }

  Future<void> signInWithNaver() async {
    _authNotifier.setLoading();
    try {
      final socialLoginResult = await _socialLoginRepository.signInWithNaver();
      if (socialLoginResult != null) {
        final SessionUser? serverUser =
            socialLoginResult['sessionUser'] as SessionUser?;
        final String? token = socialLoginResult['token']
            as String?; // 수정: socialLoginLogResult -> socialLoginResult

        if (serverUser != null && token != null && token.isNotEmpty) {
          await _authNotifier.updateUserAndAuthStatus(
              serverUser, AuthStatus.authenticated, LoginType.social,
              newToken: token);
          print("[SocialLoginNotifier] 네이버 소셜 로그인 성공: ${serverUser.loginId}");
          await _fetchProfileAndUpdateAuth(); // 공통 프로필 조회 및 업데이트 함수 호출
        } else {
          throw Exception("네이버 소셜 로그인 처리 중 서버 응답 데이터가 누락되었습니다.");
        }
      } else {
        await _authNotifier.updateUserAndAuthStatus(
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
      await _socialLoginRepository.signOutFromGoogle();

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
          await _authNotifier.updateUserAndAuthStatus(
              serverUser, AuthStatus.authenticated, LoginType.social,
              newToken: token);
          print("[SocialLoginNotifier] 구글 소셜 로그인 성공: ${serverUser.loginId}");

          bool needsServerNameUpdate = false;
          String? googleDisplayName = googleUserAccount.displayName;

          if (googleDisplayName != null &&
              serverUser.name != googleDisplayName) {
            needsServerNameUpdate = true;
          }

          if (needsServerNameUpdate) {
            print(
                "[SocialLoginNotifier] Google 프로필 이름으로 서버 프로필 업데이트 시도: Name: $googleDisplayName");
            try {
              final profileRepository = ref.read(ProfileRepositoryProvider);
              await profileRepository.updateMyProfile(
                  ProfileUpdateRequestDto(name: googleDisplayName));
              print("[SocialLoginNotifier] Google 이름으로 서버 프로필 이름 업데이트 성공.");
              // 이름 업데이트 후 최신 프로필 정보로 세션 갱신
              await _fetchProfileAndUpdateAuth();
            } catch (e) {
              print(
                  "[SocialLoginNotifier] Google 이름으로 서버 프로필 이름 업데이트 실패: ${extractErrorMessage(e)}");
              // 이름 업데이트에 실패했더라도, 일단 로그인된 정보로 프로필 가져오기 시도
              await _fetchProfileAndUpdateAuth();
            }
          } else {
            print(
                "[SocialLoginNotifier] Google 프로필 이름이 이미 최신이거나, Google 이름 정보가 없어 서버 이름 업데이트를 건너뜁니다.");
            await _fetchProfileAndUpdateAuth();
          }
        } else {
          throw Exception("구글 소셜 로그인 처리 중 필요한 데이터(유저/토큰/구글계정정보)가 누락되었습니다.");
        }
      } else {
        await _authNotifier.updateUserAndAuthStatus(
            null, AuthStatus.unauthenticated, LoginType.none);
        print(
            "[SocialLoginNotifier] 구글 소셜 로그인이 완료되지 않았습니다 (사용자 취소 또는 SDK 오류 등).");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setError("구글 로그인 실패: $errorMessage");
      print("[SocialLognNotifier] 구글 소셜 로그인 실패: $errorMessage");
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
