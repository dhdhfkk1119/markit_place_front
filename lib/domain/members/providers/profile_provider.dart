// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/sessions/session_provider.dart';
import '../../../_core/sessions/session_repository.dart';
import '../../../_core/utils/error_utils.dart';
import '../dtos/profile_update_request_dto.dart';
import '../../../_core/sessions/session_user.dart';
import '../repositories/profile_repository.dart';
import 'member_auth_provider.dart'; // TODO: SessionNotifier로 점진적 대체 필요

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends Notifier<void> {
  late ProfileRepository _profileRepository;
  late AuthNotifier _authNotifier; // TODO: SessionNotifier로 점진적 대체 필요
  // late SessionService _sessionService; // 삭제
  late SessionRepository
      _sessionRepositoryForToken; // SessionRepository를 통해 토큰 접근

  @override
  void build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _authNotifier =
        ref.watch(authNotifierProvider.notifier); // 기존 AuthNotifier 유지
    // _sessionService = ref.watch(sessionServiceProvider); // 삭제
    // SessionRepositoryProvider를 통해 SessionRepository 인스턴스를 가져옴
    // 이 SessionRepository는 SecureStorage에 접근 가능해야 함
    _sessionRepositoryForToken = ref.watch(sessionRepositoryProvider);
  }

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
      // final String? token = await _sessionService.getAccessToken(); // 변경
      final String? token =
          await _sessionRepositoryForToken.getAccessToken(); // 변경

      if (fullUserProfile != null && token != null) {
        _authNotifier.updateUserAndAuthStatus(fullUserProfile,
            AuthStatus.authenticated, currentAuthState.loginType);
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
      // final String? token = await _sessionService.getAccessToken(); // 변경
      final String? token =
          await _sessionRepositoryForToken.getAccessToken(); // 변경

      if (userFromServerAfterUpdate != null && token != null) {
        _authNotifier.updateUserAndAuthStatus(userFromServerAfterUpdate,
            AuthStatus.authenticated, currentAuthState.loginType);
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
