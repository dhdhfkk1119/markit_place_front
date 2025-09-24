import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/trade_model.dart';
import '../repository/trade_repository.dart';

class TradeListModelState {
  final List<TradeListModel> items;
  final int page;
  final bool hasNext;

  TradeListModelState({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  TradeListModelState copyWith({
    List<TradeListModel>? items,
    int? page,
    bool? hasNext,
  }) {
    return TradeListModelState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class TradeProvider extends AsyncNotifier<TradeListModelState> {
  final TradeRepository _repository = TradeRepository();

  @override
  Future<TradeListModelState> build() async {
    return loadPage(0);
  }

  Future<TradeListModelState> loadPage(int page) async {
    final response = await _repository.tradeList(page: page);
    final List<dynamic> content = response['content'];
    final List<TradeListModel> newItems =
        content.map((json) => TradeListModel.fromJson(json)).toList();
    final hasNext = !response['last'];

    final currentItems = state.value?.items ?? [];
    final allItems = page == 0 ? newItems : [...currentItems, ...newItems];

    final newState = TradeListModelState(
      items: allItems,
      page: page,
      hasNext: hasNext,
    );
    return newState;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final newState = await build();
    state = AsyncValue.data(newState);
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasNext) {
      return;
    }

    // 로딩 중이 아닐 때만 다음 페이지 로드
    if (state is AsyncLoading) {
      return;
    }

    // 다음 페이지 로드
    state = await AsyncValue.guard(() async {
      return await loadPage(currentState.page + 1);
    });
  }
}

final tradeProvider = AsyncNotifierProvider<TradeProvider, TradeListModelState>(
    () => TradeProvider());
