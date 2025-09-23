import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dtos/my_profile_response_data_dto.dart';
import '../repositories/profile_repository.dart';
import 'profile_provider.dart';

class OtherProfileNotifier extends AsyncNotifier<MyProfileResponseDataDto?> {
  late ProfileRepository _profileRepository;

  @override
  Future<MyProfileResponseDataDto?> build() async {
    _profileRepository = ref.watch(profileRepositoryProvider);
    return null;
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
  final repo = ref.watch(profileRepositoryProvider);
  return await repo.getFindByUser(userId);
});
