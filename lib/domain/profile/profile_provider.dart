import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../_core/utils/my_http.dart'; // secureStorage, tokenKey 사용 (accessTokenProvider)
// import '../members/repositories/member_auth_repository.dart'; // accessTokenProvider에서 사용 // This line seems to be unused now
// import 'profile.dart'; // ProfileEditViewModel, ProfileEditState 등 가정 // REMOVED
import '../members/repositories/member_auth_repository.dart';
import 'profile_info_dto.dart';
import 'profile_info_repository.dart';
import 'profile_repository.dart'; // 통합된 ProfileRepository

// 프로필 관련 API 레포지토리 Provider (통합된 ProfileRepository 사용)
final ProfileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(); //baseUrl 주입 삭제, Dio를 내부적으로 사용
});

// JWT 인증 토큰 Provider (비동기) - ProfileInfoFutureProvider 에서 아직 사용 중
final accessTokenProvider = FutureProvider<String>((ref) async {
  final token = await secureStorage.read(key: tokenKey);
  return token ?? '';
});

// ProfileInfoRepository 관련 Provider들은 ProfileRepository 통합과 직접적인 영향이 없을 수 있으므로 일단 유지
// 하지만 ProfileInfoRepository의 기능이 통합된 ProfileRepository와 중복/연관되는지 검토 필요
final profileInfoRepositoryProvider = Provider<ProfileInfoRepository>((ref) {
  // ProfileInfoRepository 생성 방식이 baseUrl을 필요로 하는지 확인
  return ProfileInfoRepository(
      baseUrl: baseUrl); // ProfileInfoRepository가 여전히 baseUrl을 사용한다고 가정
});

final profileInfoFutureProvider =
    FutureProvider<ProfileInfoResponseDto>((ref) async {
  final repo = ref.watch(profileInfoRepositoryProvider);
  final token =
      await ref.watch(accessTokenProvider.future); // 여기서도 accessToken을 직접 사용
  return await repo.fetchProfileInfo(accessToken: token);
});
