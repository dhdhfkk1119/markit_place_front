// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../_core/sessions/session_provider.dart'; // 삭제
// import '../../../_core/sessions/session_repository.dart'; // 삭제
import '../../../_core/utils/error_utils.dart';
import '../dtos/profile_update_request_dto.dart';
import '../models/session_user.dart';
import '../repositories/profile_repository.dart';
import '../repositories/member_auth_repository.dart'; // MemberAuthRepository import 추가
import 'member_auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends Notifier<void> {
  late ProfileRepository _profileRepository;
  late AuthNotifier _authNotifier;
  late MemberAuthRepository _memberAuthRepository; // MemberAuthRepository 추가

  @override
  void build() {
    _profileRepository = ref.watch(profileRepositoryProvider);
    _authNotifier = ref.watch(authNotifierProvider.notifier);
    _memberAuthRepository =
        ref.watch(memberAuthRepositoryProvider); // MemberAuthRepository 초기화
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
      // final String? token = await _sessionService.getAccessToken(); // 삭제
      final String? token = await _memberAuthRepository
          .getAccessToken(); // MemberAuthRepository 사용

      if (fullUserProfile != null && token != null && token.isNotEmpty) {
        // token empty 체크 추가
        // AuthNotifier의 refreshSessionUser를 사용하여 사용자 정보만 업데이트하거나,
        // updateUserAndAuthStatus를 호출 (현재 토큰은 변경되지 않으므로 newToken은 null)
        await _authNotifier.refreshSessionUser(fullUserProfile);
        // 또는 기존처럼 updateUserAndAuthStatus 호출 (이미 refreshSessionUser가 내부적으로 처리)
        // await _authNotifier.updateUserAndAuthStatus(fullUserProfile,
        //     AuthStatus.authenticated, currentAuthState.loginType);
        print(
            "[ProfileNotifier] 내 프로필 정보 조회 및 AuthNotifier 상태 업데이트 성공: ${fullUserProfile.name}");
      } else if (token == null || token.isEmpty) {
        throw Exception("프로필 조회 후 토큰 정보를 찾을 수 없어 상태를 업데이트할 수 없습니다.");
      } else if (fullUserProfile == null) {
        throw Exception("서버로부터 프로필 정보를 가져오지 못했습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setErrorOnAuthenticated("프로필 정보 조회 실패: $errorMessage");
      print("[ProfileNotifier] 내 프로필 정보 조회 실패: $errorMessage");
      // 필요시 여기서 _authNotifier.logout() 또는 _authNotifier.handleSessionInvalidation() 호출 고려
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
    _authNotifier.setLoading(); // 프로필 업데이트 시작 시 로딩 상태

    try {
      final requestDto = ProfileUpdateRequestDto(
        name: name,
        profileImage: newProfileImageBase64,
      );

      final SessionUser? userFromServerAfterUpdate =
          await _profileRepository.updateMyProfile(requestDto);
      // final String? token = await _sessionService.getAccessToken(); // 삭제
      final String? token = await _memberAuthRepository
          .getAccessToken(); // MemberAuthRepository 사용

      if (userFromServerAfterUpdate != null &&
          token != null &&
          token.isNotEmpty) {
        // token empty 체크 추가
        // 프로필 업데이트 성공 후 AuthNotifier 상태 갱신
        await _authNotifier.refreshSessionUser(userFromServerAfterUpdate);
        // 또는 기존처럼 updateUserAndAuthStatus 호출
        // await _authNotifier.updateUserAndAuthStatus(userFromServerAfterUpdate,
        //    AuthStatus.authenticated, currentAuthState.loginType);
        print(
            "[ProfileNotifier] 서버 프로필 업데이트 및 AuthNotifier 상태 반영 성공: ${userFromServerAfterUpdate.name}");
      } else if (token == null || token.isEmpty) {
        throw Exception("프로필 업데이트 후 토큰 정보를 찾을 수 없습니다.");
      } else {
        // 서버에서 업데이트된 사용자 정보가 오지 않은 경우
        throw Exception("프로필 업데이트 후 서버로부터 유효한 사용자 정보를 받지 못했습니다.");
      }
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      _authNotifier.setErrorOnAuthenticated("프로필 업데이트 실패: $errorMessage");
      print("[ProfileNotifier] 프로필 업데이트 실패: $errorMessage");
    } finally {
      // 성공/실패 여부와 관계없이 로딩 상태가 아닌 경우 프로필을 다시 한번 동기화 (선택적)
      if (_authNotifier.state.status != AuthStatus.loading) {
        await fetchMyProfileAndUpdateAuthNotifier(showLoading: false);
      }
    }
  }
}

final profileNotifierProvider = NotifierProvider<ProfileNotifier, void>(() {
  return ProfileNotifier();
});
