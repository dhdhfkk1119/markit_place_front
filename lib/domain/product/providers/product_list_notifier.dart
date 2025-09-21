import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_list_dtos.dart';
import '../models/product_list.dart';
import '../repository/product_list_repository.dart';

class ProductListNotifier extends AsyncNotifier<List<ProductListDto>> {
  final ProductListRepository _repository = ProductListRepository();

  int _currentPage = 0;
  bool _hasNext = true; // 더 불러올 데이터가 있는지 여부
  int _size = 5;

  bool get hasNext => _hasNext; // 외부에서 마지막 페이지

  @override
  Future<List<ProductListDto>> build() async {
    _currentPage = 0;
    _hasNext = true;

    final response =
        await _repository.productList(page: _currentPage, size: _size);
    final List<dynamic> content = response['content'];

    _hasNext = !response['last']; // 서버에서 last 여부 판단
    return content
        .map((json) => ProductList.fromJson(json))
        .map((model) => ProductListDto.fromModel(model))
        .toList();
  }

  // 다음 페이지 불러오기
  Future<void> fetchNextPage() async {
    if (!_hasNext) return; // 마지막 페이지면 호출 안 함

    state = AsyncValue.data(state.value ?? []); // 기존 데이터 유지

    try {
      _currentPage++;
      final response =
          await _repository.productList(page: _currentPage, size: _size);
      final List<dynamic> content = response['content'];

      _hasNext = !response['last'];

      final nextItems = content
          .map((json) => ProductList.fromJson(json))
          .map((model) => ProductListDto.fromModel(model))
          .toList();

      state = AsyncValue.data([
        ...(state.value ?? []),
        ...nextItems,
      ]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshProductList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _repository.productDelete(productId);

      final currentList = state.value ?? [];

      final updatedList = currentList.where((p) => p.id != productId).toList();

      state = AsyncValue.data(updatedList);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<ProductListDto>>(
        () => ProductListNotifier());
