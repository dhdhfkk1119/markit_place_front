// D:/workspace-flutter/markit_place_front/lib/domain/members/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../_core/utils/error_utils.dart';
import '../dtos/profile_update_request_dto.dart';
import '../models/session_user.dart';
import '../repositories/profile_repository.dart'; // ProfileRepository import
import 'member_auth_provider.dart';

// ProfileRepository Provider 정의 추가
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends Notifier<void> {
  late ProfileRepository _profileRepository;
  late FlutterSecureStorage _secureStorage;
  late AuthNotifier _authNotifier;

  @override
  void build() {
    _profileRepository = ref.watch(profileRepositoryProvider); // 여기서 주입
    _secureStorage = const FlutterSecureStorage();
    _authNotifier = ref.watch(authNotifierProvider.notifier);
  }

  static const _tokenKey = AuthNotifier.tokenKey;
  static const _userMemberIdKey = AuthNotifier.userMemberIdKey;
  static const _userLoginIdKey = AuthNotifier.userLoginIdKey;
  static const _userEmailKey = AuthNotifier.userEmailKey;
  static const _userNameKey = AuthNotifier.userNameKey;
  static const _userRoleKey = AuthNotifier.userRoleKey;
  static const _userProfileImageUrlKey = AuthNotifier.userProfileImageUrlKey;

  Future<void> _storeSessionUserInProfile(
      SessionUser sessionUser, String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(
        key: _userMemberIdKey, value: sessionUser.memberId.toString());
    await _secureStorage.write(key: _userRoleKey, value: sessionUser.role);
    if (sessionUser.loginId != null) {
      await _secureStorage.write(
          key: _userLoginIdKey, value: sessionUser.loginId!);
    } else {
      await _secureStorage.delete(key: _userLoginIdKey);
    }
    if (sessionUser.email != null) {
      await _secureStorage.write(key: _userEmailKey, value: sessionUser.email!);
    } else {
      await _secureStorage.delete(key: _userEmailKey);
    }
    if (sessionUser.name != null) {
      await _secureStorage.write(key: _userNameKey, value: sessionUser.name!);
    } else {
      await _secureStorage.delete(key: _userNameKey);
    }
    if (sessionUser.profileImageUrl != null) {
      await _secureStorage.write(
          key: _userProfileImageUrlKey, value: sessionUser.profileImageUrl!);
    } else {
      await _secureStorage.delete(key: _userProfileImageUrlKey);
    }
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
      final token = await _secureStorage.read(key: _tokenKey);

      if (fullUserProfile != null && token != null) {
        await _storeSessionUserInProfile(fullUserProfile, token);
        _authNotifier.updateUserAndAuthStatus(fullUserProfile,
            AuthStatus.authenticated, currentAuthState.loginType);
        print(
            "[ProfileNotifier] 내 프로필 정보 조회 및 AuthNotifier 상태 업데이트 성공: ${fullUserProfile.name}");
      } else if (token == null) {
        throw Exception("프로필 조회 후 토큰 정보를 찾을 수 없어 상태를 업데이트할 수 없습니다.");
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
      final token = await _secureStorage.read(key: _tokenKey);

      if (userFromServerAfterUpdate != null && token != null) {
        await _storeSessionUserInProfile(userFromServerAfterUpdate, token);
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
