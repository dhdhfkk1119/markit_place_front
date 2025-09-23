import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_list_dtos.dart';
import '../dtos/product_search_dto.dart';
import '../models/product_list.dart';
import '../repository/product_list_repository.dart';

class ProductListNotifier extends AsyncNotifier<List<ProductListDto>> {
  final ProductListRepository _repository = ProductListRepository();

  // 검색 및 페이지네이션 상태를 통합 관리하는 DTO
  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  Future<List<ProductListDto>> build() async {
    // build 메소드는 첫 페이지만 불러오는 역할
    return _fetchProducts(page: 0);
  }

  Future<List<ProductListDto>> _fetchProducts(
      {required int page, String? keyword}) async {
    // Repository에 상품 목록 요청
    final searchDto = ProductSearchDTO(page: page, keyword: keyword);
    final pageData = await _repository.getProducts(searchDto);

    // Notifier의 페이지 상태 업데이트
    _currentPage = page;
    _isLastPage = pageData.isLastPage;

    // Model -> DTO 변환
    final dtoList = pageData.productList
        .map((model) => ProductListDto.fromModel(model))
        .toList();

    return dtoList;
  }

  // 새로운 검색어/조건으로 검색
  Future<void> searchProducts(ProductSearchDTO? product) async {
    state = const AsyncValue.loading();
    // guard는 try-catch를 자동으로 해줘서 편리해
    state = await AsyncValue.guard(
        () => _fetchProducts(page: 0, keyword: product!.keyword));
  }

  // 다음 페이지 불러오기 (페이지네이션)
  Future<void> fetchNextPage() async {
    // 3. 로딩 중이거나 마지막 페이지이면 더 이상 호출하지 않음
    if (state.isLoading || _isLastPage) return;

    // 현재 데이터를 유지하면서 로딩 상태 표시 (화면 깜빡임 방지)
    state = AsyncValue.loading();

    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchProducts(page: nextPage);

      state = AsyncValue.data([
        ...(state.value ?? []), // 기존 리스트
        ...nextItems, // 새로 불러온 리스트 추가
      ]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // 목록 새로고침
  Future<void> refreshProductList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
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
