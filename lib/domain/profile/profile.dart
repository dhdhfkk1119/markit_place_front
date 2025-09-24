import 'package:flutter_riverpod/flutter_riverpod.dart';

// 기존 profile_dto.dart의 DTO 대신 새로운 DTO를 사용하거나, SessionUser 모델을 직접 사용
// import 'profile_dto.dart'; // ProfileEditRequestDto, ProfileEditResponseDto 정의 파일 - 사용 안 할 가능성 높음
import '../members/dtos/profile_update_request_dto.dart'; // 통합된 리포지토리가 사용하는 DTO
import '../members/models/session_user.dart'; // 통합된 리포지토리의 응답 타입
import './profile_provider.dart'; // ProfileRepositoryProvider를 위해 추가
import './profile_repository.dart'; // 통합된 ProfileRepository

// 프로필 수정 상태를 관리하는 State 클래스
class ProfileEditState {
  final bool isLoading;
  final String? error;
  final SessionUser? response; // 응답 타입을 SessionUser? 로 변경
  ProfileEditState({this.isLoading = false, this.error, this.response});

  // 상태 복사 및 변경 메서드
  ProfileEditState copyWith({
    bool? isLoading,
    String? error,
    SessionUser? response, // 응답 타입을 SessionUser? 로 변경
  }) =>
      ProfileEditState(
        isLoading: isLoading ?? this.isLoading,
        error: error, // error: null 대신 error 전달로 수정 (이전 코드 참조)
        response: response ?? this.response,
      );
}

// 프로필 수정 비즈니스 로직을 담당하는 ViewModel
class ProfileEditViewModel extends StateNotifier<ProfileEditState> {
  final ProfileRepository repository;

  // accessToken은 Repository에서 Dio 인터셉터로 처리하므로 ViewModel에서 직접 관리할 필요 없음

  ProfileEditViewModel({required this.repository}) : super(ProfileEditState());

  // 프로필 수정 API 호출 및 상태 갱신
  Future<void> editProfile({String? name, String? profileImageBase64}) async {
    // profileImage -> profileImageBase64 (DTO에 맞춤)
    state = state.copyWith(isLoading: true, error: null);
    try {
      // ProfileEditRequestDto 대신 ProfileUpdateRequestDto 사용
      final dto =
          ProfileUpdateRequestDto(name: name, profileImage: profileImageBase64);
      // repository.editProfile 대신 repository.updateMyProfile 호출
      // accessToken 전달 제거
      final res = await repository.updateMyProfile(dto);
      state = state.copyWith(isLoading: false, response: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 프로필 수정 ViewModel Provider
final profileEditViewModelProvider =
    StateNotifierProvider<ProfileEditViewModel, ProfileEditState>((ref) {
  final repo =
      ref.watch(ProfileRepositoryProvider); // ./profile_provider.dart 에서 import
  return ProfileEditViewModel(repository: repo);
});
