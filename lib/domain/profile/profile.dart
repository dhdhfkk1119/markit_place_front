import 'dart:io'; // File 사용은 이제 직접적으로 하지 않지만, 혹시 모를 다른 부분 위해 유지 (제거 가능성 있음)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../members/dtos/profile_update_request_dto.dart';
import '../members/models/session_user.dart';
import './profile_provider.dart';
import './profile_repository.dart';

class ProfileEditState {
  final bool isLoading;
  final String? error;
  final SessionUser? response;
  ProfileEditState({this.isLoading = false, this.error, this.response});

  ProfileEditState copyWith({
    bool? isLoading,
    String? error,
    SessionUser? response,
  }) =>
      ProfileEditState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        response: response ?? this.response,
      );
}

class ProfileEditViewModel extends StateNotifier<ProfileEditState> {
  final ProfileRepository repository;

  ProfileEditViewModel({required this.repository}) : super(ProfileEditState());

  // 파라미터 변경: profileImageFile -> profileImageBase64
  Future<void> editProfile({String? name, String? profileImageBase64}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // DTO 생성 시 profileImageBase64를 profileImage 필드에 전달 (DTO 수정 필요)
      final dto = ProfileUpdateRequestDto(
        name: name,
        profileImage:
            profileImageBase64, // DTO의 profileImage 필드가 Base64 문자열을 받도록 수정 예정
        // profileImageFile: null, // 이 필드는 DTO에서 제거되거나 사용되지 않음
      );
      final res = await repository.updateMyProfile(dto);
      state = state.copyWith(isLoading: false, response: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileEditViewModelProvider =
    StateNotifierProvider<ProfileEditViewModel, ProfileEditState>((ref) {
  final repo = ref.watch(ProfileRepositoryProvider);
  return ProfileEditViewModel(repository: repo);
});
