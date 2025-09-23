import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_dto.dart';
import 'profile_repository.dart';

// 프로필 수정 상태를 관리하는 State 클래스
class ProfileEditState {
  final bool isLoading;
  final String? error;
  final ProfileEditResponseDto? response;
  ProfileEditState({this.isLoading = false, this.error, this.response});

  // 상태 복사 및 변경 메서드
  ProfileEditState copyWith({
    bool? isLoading,
    String? error,
    ProfileEditResponseDto? response,
  }) =>
      ProfileEditState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        response: response ?? this.response,
      );
}

// 프로필 수정 비즈니스 로직을 담당하는 ViewModel
class ProfileEditViewModel extends StateNotifier<ProfileEditState> {
  final ProfileRepository repository;
  final String accessToken;
  ProfileEditViewModel({required this.repository, required this.accessToken})
      : super(ProfileEditState());

  // 프로필 수정 API 호출 및 상태 갱신
  Future<void> editProfile({String? name, String? profileImage}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dto = ProfileEditRequestDto(name: name, profileImage: profileImage);
      final res =
          await repository.editProfile(accessToken: accessToken, dto: dto);
      state = state.copyWith(isLoading: false, response: res);
    } catch (e) {
      // 서버 에러 메시지 원문을 최대한 출력
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
