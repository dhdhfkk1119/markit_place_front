import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_detail_dto.dart';
import '../models/product_detail.dart';
import '../repository/product_detail_repository.dart';
import 'product_list_notifier.dart';

// FamilyAsyncNotifier를 사용
// product_detail_notifier.dart
class ProductDetailNotifier extends FamilyAsyncNotifier<ProductDetailDto, int> {
  // _repository 변수를 선언하지 않습니다.

  @override
  Future<ProductDetailDto> build(int itemId) async {
    // repository는 이 메서드 내에서만 사용합니다.
    final repository = ref.read(productDetailRepositoryProvider);

    try {
      final productDetailModel = await repository.productDetail(itemId: itemId);
      return ProductDetailDto.fromModel(productDetailModel);
    } catch (e) {
      throw Exception("서버를 연결할 수 없습니다.");
    }
  }

  Future<void> toggleFavorite(int itemId) async {
    if (state.value == null) return;

    // toggleFavorite 메서드 내에서도 repository를 다시 읽어서 사용합니다.
    final repository = ref.read(productDetailRepositoryProvider);
    final currentProductDetail = state.value!;

    try {
      final status = await repository.productFavorite(itemId: itemId);
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
      throw Exception("좋아요 처리 실패: $e");
    }
  }
}

// provider 정의
final productDetailProvider =
    AsyncNotifierProvider.family<ProductDetailNotifier, ProductDetailDto, int>(
  () => ProductDetailNotifier(),
);
