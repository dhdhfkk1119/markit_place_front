import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../praise_repository/manner_praise_repository.dart';

class MannerPraiseNotifier extends StateNotifier<bool> {
  final MannerPraiseRepository _repository;

  MannerPraiseNotifier(this._repository) : super(false);

  Future<void> praiseManner(int sellerId, String praiseType) async {
    state = true;
    try {
      await _repository.praiseManner(sellerId, praiseType);
      state = false;
    } catch (e) {
      state = false;
    }
  }
}

final mannerPraiseProvider =
    StateNotifierProvider<MannerPraiseNotifier, bool>((ref) {
  final dio = Dio();
  final repository = MannerPraiseRepository(dio);
  return MannerPraiseNotifier(repository);
});
