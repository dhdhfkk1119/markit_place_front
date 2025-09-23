import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../members/repositories/member_auth_repository.dart';
import 'profile.dart';
import 'profile_repository.dart';
import 'profile_info_repository.dart';
import 'profile_info_dto.dart';
import '../../../../_core/utils/my_http.dart'; // baseUrl, secureStorage, tokenKey import

// 프로필 관련 API 레포지토리 Provider
final ProfileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // my_http.dart의 baseUrl 사용
  return ProfileRepository(baseUrl: baseUrl);
});

// JWT 인증 토큰 Provider (비동기)
final accessTokenProvider = FutureProvider<String>((ref) async {
  final token = await secureStorage.read(key: tokenKey);
  return token ?? '';
});

// 프로필 수정 ViewModel Provider (비동기 토큰 주입)
final profileEditViewModelProvider =
    StateNotifierProvider<ProfileEditViewModel, ProfileEditState>((ref) {
  final repo = ref.watch(ProfileRepositoryProvider);
  final token = ref
      .watch(accessTokenProvider)
      .maybeWhen(data: (t) => t, orElse: () => '');
  return ProfileEditViewModel(repository: repo, accessToken: token);
});

final profileInfoRepositoryProvider = Provider<ProfileInfoRepository>((ref) {
  return ProfileInfoRepository(baseUrl: baseUrl);
});

final profileInfoFutureProvider =
    FutureProvider<ProfileInfoResponseDto>((ref) async {
  final repo = ref.watch(profileInfoRepositoryProvider);
  final token = await ref.watch(accessTokenProvider.future);
  return await repo.fetchProfileInfo(accessToken: token);
});
