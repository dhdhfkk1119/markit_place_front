// // D:/workspace-flutter/markit_place_front/lib/domain/members/providers/profile_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../_core/utils/error_utils.dart';
// import '../dtos/profile_update_request_dto.dart'; // ProfileNotifier에서 사용
// import '../models/session_user.dart'; // ProfileNotifier에서 사용
// // 통합된 ProfileRepository를 사용하기 위해 경로 수정 및 alias 사용
// import '../../../domain/profile/profile_repository.dart' as domain_profile_repo;
// import '../repositories/member_auth_repository.dart';
// import 'member_auth_provider.dart';
//
// // Provider가 반환하는 타입을 통합된 ProfileRepository로 변경
// final profileRepositoryProvider =
//     Provider<domain_profile_repo.ProfileRepository>((ref) {
//   return domain_profile_repo
//       .ProfileRepository(); // domain/profile/profile_repository.dart의 인스턴스 반환
// });
//
// class ProfileNotifier extends Notifier<void> {
//   // _profileRepository의 타입을 통합된 ProfileRepository로 변경
//   late domain_profile_repo.ProfileRepository _profileRepository;
//   late AuthNotifier _authNotifier;
//   late MemberAuthRepository _memberAuthRepository;
//
//   @override
//   void build() {
//     _profileRepository =
//         ref.watch(profileRepositoryProvider); // 수정된 provider watch
//     _authNotifier = ref.watch(authNotifierProvider.notifier);
//     _memberAuthRepository = ref.watch(memberAuthRepositoryProvider);
//   }
//
//   Future<void> fetchMyProfileAndUpdateAuthNotifier(
//       {bool showLoading = true}) async {
//     final currentAuthState = _authNotifier.state;
//     if (currentAuthState.status != AuthStatus.authenticated ||
//         currentAuthState.user == null) {
//       print("[ProfileNotifier] 프로필 조회 건너뜀: 사용자가 인증되지 않았거나 사용자 정보 없음.");
//       return;
//     }
//
//     if (showLoading) {
//       _authNotifier.setLoading();
//     }
//
//     try {
//       // _profileRepository는 이제 domain_profile_repo.ProfileRepository 인스턴스임
//       final SessionUser? fullUserProfile =
//           await _profileRepository.getMyProfile();
//       final String? token = await _memberAuthRepository.getAccessToken();
//
//       if (fullUserProfile != null && token != null && token.isNotEmpty) {
//         await _authNotifier.refreshSessionUser(fullUserProfile);
//         print(
//             "[ProfileNotifier] 내 프로필 정보 조회 및 AuthNotifier 상태 업데이트 성공: \${fullUserProfile.name}");
//       } else if (token == null || token.isEmpty) {
//         throw Exception("프로필 조회 후 토큰 정보를 찾을 수 없어 상태를 업데이트할 수 없습니다.");
//       } else if (fullUserProfile == null) {
//         throw Exception("서버로부터 프로필 정보를 가져오지 못했습니다.");
//       }
//     } catch (e) {
//       final errorMessage = extractErrorMessage(e);
//       _authNotifier.setErrorOnAuthenticated("프로필 정보 조회 실패: $errorMessage");
//       print("[ProfileNotifier] 내 프로필 정보 조회 실패: $errorMessage");
//     }
//   }
//
//   Future<void> updateProfile(
//       {String? name, String? newProfileImageBase64}) async {
//     final currentAuthState = _authNotifier.state;
//     if (currentAuthState.user == null) {
//       print("[ProfileNotifier] 프로필 업데이트 실패: 사용자가 로그인되어 있지 않음.");
//       _authNotifier.setErrorOnAuthenticated("프로필 업데이트 실패: 로그인 정보 없음");
//       return;
//     }
//     if (name == null && newProfileImageBase64 == null) {
//       print("[ProfileNotifier] 프로필 업데이트: 변경 사항 없음.");
//       return;
//     }
//
//     print(
//         "[ProfileNotifier] 서버 프로필 업데이트 요청: 이름: $name, 새 이미지 Base64 제공 여부: \${newProfileImageBase64 != null}");
//     _authNotifier.setLoading();
//
//     try {
//       final requestDto = ProfileUpdateRequestDto(
//         name: name,
//         profileImage: newProfileImageBase64,
//       );
//
//       // _profileRepository는 이제 domain_profile_repo.ProfileRepository 인스턴스임
//       final SessionUser? userFromServerAfterUpdate =
//           await _profileRepository.updateMyProfile(requestDto);
//       final String? token = await _memberAuthRepository.getAccessToken();
//
//       if (userFromServerAfterUpdate != null &&
//           token != null &&
//           token.isNotEmpty) {
//         await _authNotifier.refreshSessionUser(userFromServerAfterUpdate);
//         print(
//             "[ProfileNotifier] 서버 프로필 업데이트 및 AuthNotifier 상태 반영 성공: \${userFromServerAfterUpdate.name}");
//       } else if (token == null || token.isEmpty) {
//         throw Exception("프로필 업데이트 후 토큰 정보를 찾을 수 없습니다.");
//       } else {
//         throw Exception("프로필 업데이트 후 서버로부터 유효한 사용자 정보를 받지 못했습니다.");
//       }
//     } catch (e) {
//       final errorMessage = extractErrorMessage(e);
//       _authNotifier.setErrorOnAuthenticated("프로필 업데이트 실패: $errorMessage");
//       print("[ProfileNotifier] 프로필 업데이트 실패: $errorMessage");
//     } finally {
//       if (_authNotifier.state.status != AuthStatus.loading) {
//         await fetchMyProfileAndUpdateAuthNotifier(showLoading: false);
//       }
//     }
//   }
// }
//
// final profileNotifierProvider = NotifierProvider<ProfileNotifier, void>(() {
//   return ProfileNotifier();
// });
