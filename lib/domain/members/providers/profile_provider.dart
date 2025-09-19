// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // SessionService를 사용하므로 직접 참조 제거
import '../../../_core/utils/error_utils.dart';
import '../dtos/profile_update_request_dto.dart';
import '../models/session_user.dart';
import '../repositories/profile_repository.dart';
import 'member_auth_provider.dart';
import '../services/session_service.dart'; // SessionService import 추가

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends Notifier<void> {
  late ProfileRepository _profileRepository;
  late AuthNotifier _authNotifier;
  late SessionService _sessionService; // SessionService 필드 추가

  @override
  void build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _authNotifier = ref.watch(authNotifierProvider.notifier);
    _sessionService = ref.watch(sessionServiceProvider); // SessionService 초기화
  }

  // AuthNotifier의 static 키 직접 참조 제거
  // static const _tokenKey = AuthNotifier.tokenKey;
  // ... (다른 키들도 제거)

  // _storeSessionUserInProfile 메소드 삭제
  // Future<void> _storeSessionUserInProfile(SessionUser sessionUser, String token) async { ... }

  Future<void> fetchMyProfileAndUpdateAuthNotifier(
      {bool showLoading = true}) async {
    final currentAuthState = _authNotifier.state;
    if (currentAuthState.status != AuthStatus.authenticated ||
        currentAuthState.user == null) {
      print("[ProfileNotifier] 프로필 조회 건너뜀: 사용자가 인증되지 않았거나 사용자 정보 없음.");
      return;
    }

    if (showLoading) {
      _authNotifier.setLoading();
    }

    try {
      final SessionUser? fullUserProfile =
          await _profileRepository.getMyProfile();
      final String? token =
          await _sessionService.getAccessToken(); // SessionService 사용

      if (fullUserProfile != null && token != null) {
        // _storeSessionUserInProfile 호출 제거 - AuthNotifier가 SessionUser 상태 변경 시 SessionService를 통해 처리
        _authNotifier.updateUserAndAuthStatus(fullUserProfile,
            AuthStatus.authenticated, currentAuthState.loginType);
        // AuthNotifier는 내부적으로 updateUserAndAuthStatus가 호출될 때,
        // 필요하다면 SessionService를 통해 변경된 SessionUser 정보를 SecureStorage에 업데이트해야 합니다.
        // (현재 AuthNotifier는 login시에만 SessionService.storeSession을 명시적으로 호출하고,
        // updateUserAndAuthStatus 자체는 직접 SecureStorage를 업데이트 하지 않습니다.
        // 이는 ProfileNotifier의 책임이 아니라 AuthNotifier의 책임입니다.)
        // 중요한 점: `AuthNotifier`의 `updateUserAndAuthStatus`가 호출된 후,
        // `AuthNotifier`의 `state.user`가 `fullUserProfile`로 업데이트됩니다.
        // 이 변경된 `state.user` 정보는 다음에 `SessionService.storeSession`이 호출될 때 (예: 다음번 자동로그인 설정 시 또는 명시적 저장 호출 시) 반영됩니다.
        // 만약 프로필 업데이트 즉시 SecureStorage에도 반영되어야 한다면,
        // AuthNotifier의 updateUserAndAuthStatus 내부에서 SessionService.storeSession을 호출하도록 수정해야 합니다.
        // 하지만 지금은 ProfileNotifier의 수정에 집중합니다.
        print(
            "[ProfileNotifier] 내 프로필 정보 조회 및 AuthNotifier 상태 업데이트 성공: ${fullUserProfile.name}");
      } else if (token == null) {
        throw Exception("프로필 조회 후 토큰 정보를 찾을 수 없어 상태를 업데이트할 수 없습니다.");
      } else if (fullUserProfile == null) {
        throw Exception("서버로부터 프로필 정보를 가져오지 못했습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setErrorOnAuthenticated("프로필 정보 조회 실패: $errorMessage");
      print("[ProfileNotifier] 내 프로필 정보 조회 실패: $errorMessage");
    }
  }

  Future<void> updateProfile(
      {String? name, String? newProfileImageBase64}) async {
    final currentAuthState = _authNotifier.state;
    if (currentAuthState.user == null) {
      print("[ProfileNotifier] 프로필 업데이트 실패: 사용자가 로그인되어 있지 않음.");
      _authNotifier.setErrorOnAuthenticated("프로필 업데이트 실패: 로그인 정보 없음");
      return;
    }
    if (name == null && newProfileImageBase64 == null) {
      print("[ProfileNotifier] 프로필 업데이트: 변경 사항 없음.");
      return;
    }

    print(
        "[ProfileNotifier] 서버 프로필 업데이트 요청: 이름: $name, 새 이미지 Base64 제공 여부: ${newProfileImageBase64 != null}");

    try {
      final requestDto = ProfileUpdateRequestDto(
        name: name,
        profileImage: newProfileImageBase64,
      );

      final SessionUser? userFromServerAfterUpdate =
          await _profileRepository.updateMyProfile(requestDto);
      final String? token =
          await _sessionService.getAccessToken(); // SessionService 사용

      if (userFromServerAfterUpdate != null && token != null) {
        // _storeSessionUserInProfile 호출 제거
        _authNotifier.updateUserAndAuthStatus(userFromServerAfterUpdate,
            AuthStatus.authenticated, currentAuthState.loginType);
        // 위와 동일하게 AuthNotifier가 SessionUser 업데이트를 담당.
        print(
            "[ProfileNotifier] 서버 프로필 업데이트 및 AuthNotifier 상태 반영 성공: ${userFromServerAfterUpdate.name}");
      } else if (token == null) {
        throw Exception("프로필 업데이트 후 토큰 정보를 찾을 수 없습니다.");
      } else {
        throw Exception("프로필 업데이트 후 서버로부터 유효한 사용자 정보를 받지 못했습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setErrorOnAuthenticated("프로필 업데이트 실패: $errorMessage");
      print("[ProfileNotifier] 프로필 업데이트 실패: $errorMessage");
    }
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, void>(() {
  return ProfileNotifier();
});
