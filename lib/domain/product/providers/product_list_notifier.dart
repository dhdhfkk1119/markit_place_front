import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_list_dtos.dart';
import '../dtos/product_search_dto.dart';
import '../models/product_list.dart';
import '../repository/product_list_repository.dart';

class ProductListNotifier extends AsyncNotifier<List<ProductListDto>> {
  final ProductListRepository _repository = ProductListRepository();

  // 검색 및 페이지네이션 상태를 통합 관리하는 DTO
  ProductSearchDTO _searchDto = const ProductSearchDTO();
  bool get hasNext => _searchDto.hasNext ?? false;

  @override
  Future<List<ProductListDto>> build() async {
    // 새로운 검색을 시작할 때, 페이지를 0으로 초기화
    _searchDto = _searchDto.copyWith(page: 0);

    // _searchDto를 사용하여 Repository에 상품 목록 요청
    final response = await _repository.getProducts(_searchDto);
    final List<dynamic> content = response['content'];

    // 서버 응답에 따라 다음 페이지 존재 여부 업데이트
    _searchDto = _searchDto.copyWith(hasNext: !response['last']);

    return content
        .map((json) => ProductList.fromJson(json))
        .map((model) => ProductListDto.fromModel(model))
        .toList();
  }

  // 새로운 검색어/조건으로 검색
  Future<void> searchProducts(ProductSearchDTO newSearchDto) async {
    // 검색 조건 업데이트 (페이지는 0으로 초기화)
    _searchDto = newSearchDto.copyWith(page: 0);

    // 로딩 상태로 변경하고 build()를 호출하여 새 검색 시작
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  // 다음 페이지 불러오기 (페이지네이션)
  Future<void> fetchNextPage() async {
    // _searchDto의 hasNext 값을 사용하여 다음 페이지 존재 여부 확인
    if (!(_searchDto.hasNext ?? false)) return;

    // 기존 데이터를 유지하여 로딩 중에도 화면에 표시
    state = AsyncValue.data(state.value ?? []);

    try {
      // 페이지 번호를 1 증가시키고, _searchDto를 사용하여 다음 페이지 요청
      _searchDto = _searchDto.copyWith(page: _searchDto.page + 1);
      final response = await _repository.getProducts(_searchDto);
      final List<dynamic> content = response['content'];

      // 서버 응답에 따라 다음 페이지 존재 여부 업데이트
      _searchDto = _searchDto.copyWith(hasNext: !response['last']);

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

  // 목록 새로고침
  Future<void> refreshProductList() async {
    // 검색 조건을 기본값으로 초기화
    _searchDto = const ProductSearchDTO();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  // 상품 삭제
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
