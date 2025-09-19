import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_list_dtos.dart';
import '../models/product_list.dart';
import '../repository/product_list_repository.dart';

// 로딩 상태와 에러 상태도 자동으로 관리됩니다.
class ProductListNotifier extends AsyncNotifier<List<ProductListDto>> {
  final ProductListRepository _repository = ProductListRepository();

  @override
  Future<List<ProductListDto>> build() async {
    final response = await _repository.productList();
    final List<dynamic> content = response['content'];

    return content
        .map((json) => ProductList.fromJson(json))
        .map((model) => ProductListDto.fromModel(model))
        .toList();
  }

  // 데이터 새로고침 기능을 위한 메서드
  Future<void> refreshProductList() async {
    state = const AsyncLoading(); // 수동으로 로딩 상태로 변경
    // state = AsyncValue.loading();
    state = await AsyncValue.guard(() => build()); // build()를 다시 호출하여 상태 업데이트
  }
}

// provider를 AsyncNotifierProvider로 변경
final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<ProductListDto>>(
        () => ProductListNotifier());
