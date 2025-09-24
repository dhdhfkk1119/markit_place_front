import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_list_dtos.dart';
import '../dtos/product_search_dto.dart';
import '../models/product_list.dart';
import '../repository/product_list_repository.dart';

class ProductListNotifier extends AsyncNotifier<List<ProductListDto>> {
  final ProductListRepository _repository = ProductListRepository();

  ProductSearchDTO _currentSearchDto = const ProductSearchDTO();

  @override
  Future<List<ProductListDto>> build() async {
    // build 메소드는 첫 페이지만 불러오는 역할
    return _fetchProducts(page: 0);
  }

  Future<List<ProductListDto>> _fetchProducts({required int page}) async {
    // DTO의 페이지 정보만 업데이트
    _currentSearchDto = _currentSearchDto.copyWith(page: page);

    final pageData = await _repository.getProducts(_currentSearchDto);

    _currentSearchDto = _currentSearchDto.copyWith(
      hasNext: !pageData.isLastPage,
    );

    final dtoList = pageData.productList
        .map((model) => ProductListDto.fromModel(model))
        .toList();

    return dtoList;
  }

  Future<void> updateSearch(ProductSearchDTO newConditions) async {
    state = const AsyncValue.loading();

    _currentSearchDto = _currentSearchDto.copyWith(
      keyword: newConditions.keyword,
      sortBy: newConditions.sortBy,
      tags: newConditions.tags,
      sortOrder: newConditions.sortOrder,
      minPrice: newConditions.minPrice,
      maxPrice: newConditions.maxPrice,
      itemCategoryId: newConditions.itemCategoryId,
    );

    // 첫 페이지부터 다시 검색
    state = await AsyncValue.guard(() => _fetchProducts(page: 0));
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !(_currentSearchDto.hasNext ?? true)) return;

    final currentItems = state.value ?? [];
    final nextPage = (_currentSearchDto.page ?? 0) + 1;

    try {
      final nextItems = await _fetchProducts(page: nextPage);

      // 페이지 갱신
      _currentSearchDto = _currentSearchDto.copyWith(page: nextPage);

      state = AsyncValue.data([...currentItems, ...nextItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // 목록 새로고침
  Future<void> refreshProductList() async {
    _currentSearchDto = const ProductSearchDTO(); // 필터 초기화
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts(page: 0));
  }

  void updateItemFavoriteStatus(int itemId, int newFavoriteCount) {
    if (state.value == null) return;

    final updatedList = state.value!.map((item) {
      if (item.id == itemId) {
        return item.copyWith(favoriteCount: newFavoriteCount);
      }
      return item;
    }).toList();

    state = AsyncValue.data(updatedList);
  }

  // 상품 삭제
  Future<void> deleteProduct(int productId) async {
    try {
      final success = await _repository.productDelete(productId);
      if (success) {
        // UI 낙관적 업데이트 (서버 응답을 기다리지 않고 UI를 먼저 변경)
        final currentList = state.value ?? [];
        final updatedList =
            currentList.where((p) => p.id != productId).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e, st) {
      // 에러가 발생하면 원래 상태로 되돌리거나 에러 메시지 표시
      state = AsyncError(e, st);
    }
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<ProductListDto>>(
        () => ProductListNotifier());
