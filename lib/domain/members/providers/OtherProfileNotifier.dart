import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dtos/my_profile_response_data_dto.dart';
// import '../repositories/profile_repository.dart'; // 삭제
import '../../../domain/profile/profile_repository.dart'
    as domain_profile_repo; // 추가
// import 'profile_provider.dart'; // 삭제 또는 주석 처리 (members 아래의 profile_provider는 주석처리 되었으므로)
import '../../../domain/profile/profile_provider.dart'; // domain/profile 아래의 profile_provider.dart를 임포트

class OtherProfileNotifier extends AsyncNotifier<MyProfileResponseDataDto?> {
  late domain_profile_repo.ProfileRepository _profileRepository; // 타입 변경

  @override
  Future<MyProfileResponseDataDto?> build() async {
    // profileRepositoryProvider는 이제 domain/profile/profile_provider.dart 에서 가져옴
    _profileRepository = ref.watch(ProfileRepositoryProvider);
    return null; // 초기 상태는 null
  }

  Future<void> fetchUserProfile(int id) async {
    state = const AsyncValue.loading();
    try {
      final dto = await _profileRepository.getFindByUser(id);
      state = AsyncValue.data(dto);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProfileProvider =
    FutureProvider.family<MyProfileResponseDataDto?, int>((ref, userId) async {
  // repo의 타입은 domain_profile_repo.ProfileRepository가 됨
  final repo = ref.watch(ProfileRepositoryProvider);
  return await repo.getFindByUser(userId);
});
