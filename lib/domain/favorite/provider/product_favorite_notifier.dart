import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/product_favorite.dart';
import '../repository/product_favorite_repository.dart';

class ProductFavoriteListState {
  final List<ProductFavoriteModel> items;
  final int page;
  final bool hasNext;

  ProductFavoriteListState({
    required this.items,
    required this.page,
    required this.hasNext,
  });

  ProductFavoriteListState copyWith({
    List<ProductFavoriteModel>? items,
    int? page,
    bool? hasNext,
  }) {
    return ProductFavoriteListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}

class ProductFavoriteNotifier extends AsyncNotifier<ProductFavoriteListState> {
  final ProductFavoriteRepository _repository = ProductFavoriteRepository();

  @override
  Future<ProductFavoriteListState> build() async {
    return loadPage(0); // 초기 페이지 로딩
  }

  Future<ProductFavoriteListState> loadPage(int page) async {
    final response = await _repository.productFavorite(page: page);
    final List<dynamic> content = response['content'];
    final List<ProductFavoriteModel> newItems =
        content.map((json) => ProductFavoriteModel.fromJson(json)).toList();

    final hasNext = !response['last']; // 마지막 페이지 여부
    final currentItems = state.value?.items ?? [];
    final allItems = page == 0 ? newItems : [...currentItems, ...newItems];

    final newState = ProductFavoriteListState(
      items: allItems,
      page: page,
      hasNext: hasNext,
    );

    state = AsyncValue.data(newState);
    return newState;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => loadPage(0));
  }

  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasNext) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith());

    final result =
        await AsyncValue.guard(() => loadPage(currentState.page + 1));
    state = result.when(
      data: (data) => AsyncValue.data(data),
      loading: () => AsyncValue.data(currentState),
      error: (err, stack) => AsyncValue.error(err, stack),
    );
  }
}

final productFavoriteListProvider =
    AsyncNotifierProvider<ProductFavoriteNotifier, ProductFavoriteListState>(
        () => ProductFavoriteNotifier());
