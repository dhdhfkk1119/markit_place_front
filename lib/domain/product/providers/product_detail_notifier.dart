import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_detail_dto.dart';
import '../models/product_detail.dart';
import '../repository/product_detail_repository.dart';
import 'product_list_notifier.dart';

// FamilyAsyncNotifier를 사용
class ProductDetailNotifier extends FamilyAsyncNotifier<ProductDetailDto, int> {
  late final ProductDetailRepository _repository;

  @override
  Future<ProductDetailDto> build(int itemId) async {
    _repository = ref.read(productDetailRepositoryProvider);

    // ref.keepAlive()를 호출하여 Provider의 상태를 유지합니다.
    // 이렇게 하면 화면이 재빌드되어도 Provider가 초기화되지 않아 경쟁 상태를 방지할 수 있습니다.
    ref.keepAlive();

    try {
      final productDetailModel =
          await _repository.productDetail(itemId: itemId);
      return ProductDetailDto.fromModel(productDetailModel);
    } catch (e) {
      // 서버에서 가공된 구체적인 오류 메시지를 그대로 UI로 전달하기 위해 rethrow 합니다.
      rethrow;
    }
  }

  Future<void> toggleFavorite(int itemId) async {
    if (state.value == null) return;

    final currentProductDetail = state.value!;

    try {
      final status = await _repository.productFavorite(itemId: itemId);
      final newProductList = currentProductDetail.productList.copyWith(
        favoriteCount: status.favoriteCount,
      );

      final newState = currentProductDetail.copyWith(
        liked: status.liked,
        productList: newProductList,
      );

      state = AsyncValue.data(newState);

      ref.read(productListProvider.notifier).updateItemFavoriteStatus(
            itemId,
            status.favoriteCount,
          );
    } catch (e) {
      // 여기도 구체적인 에러를 전달하도록 rethrow로 변경합니다.
      rethrow;
    }
  }
}

// provider 정의
final productDetailProvider =
    AsyncNotifierProvider.family<ProductDetailNotifier, ProductDetailDto, int>(
  () => ProductDetailNotifier(),
);
