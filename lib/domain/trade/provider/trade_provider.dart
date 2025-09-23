import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/trade_model.dart';
import '../repository/trade_repository.dart';

class TradeProvider extends AsyncNotifier<List<TradeListModel>> {
  final TradeRepository _repository = TradeRepository();

  @override
  Future<List<TradeListModel>> build() async {
    final response = await _repository.tradeList();
    final List<dynamic> content = response['response'];
    return content.map((json) => TradeListModel.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final tradeProvider =
    AsyncNotifierProvider<TradeProvider, List<TradeListModel>>(
        () => TradeProvider());
