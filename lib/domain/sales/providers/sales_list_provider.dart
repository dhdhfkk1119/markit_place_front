import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/sales_model.dart';
import '../repository/sales_repository.dart';

// 페이지네이션 상태 모델
class SalesListState {
  final List<SalesModel> items;
  final int page;
  final bool hasNext;

  SalesListState({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  SalesListState copyWith({
    List<SalesModel>? items,
    int? page,
    bool? hasNext,
  }) {
    return SalesListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class SalesListProvider extends AsyncNotifier<SalesListState> {
  final SalesRepository _repository = SalesRepository();

  @override
  Future<SalesListState> build() async {
    return loadPage(0); // 초기 페이지 로딩
  }

  Future<SalesListState> loadPage(int page) async {
    state = AsyncValue.loading();
    final response = await _repository.salesList(page: page);
    final List<dynamic> content = response['content'];
    final List<SalesModel> newItems =
        content.map((json) => SalesModel.fromJson(json)).toList();

    final hasNext = !response['last']; // 마지막 페이지 여부 확인

    final currentItems = state.value?.items ?? [];
    final allItems = page == 0 ? newItems : [...currentItems, ...newItems];

    final newState = SalesListState(
      items: allItems,
      page: page,
      hasNext: hasNext,
    );

    state = AsyncValue.data(newState);
    return newState;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final newState = await loadPage(0);
    state = AsyncValue.data(newState);
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasNext) {
      return;
    }

    if (state is AsyncLoading) {
      return;
    }

    state = await AsyncValue.guard(() async {
      return await loadPage(currentState.page + 1);
    });
  }
}

final salesListProvider =
    AsyncNotifierProvider<SalesListProvider, SalesListState>(
        () => SalesListProvider());
