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
    // itemId는 build의 인자로 바로 받음
    try {
      final productDetailModel =
          await _repository.productDetail(itemId: itemId);
      return ProductDetailDto.fromModel(productDetailModel);
    } catch (e) {
      throw Exception("서버를 연결할수없습니다");
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
      throw Exception("좋아요 처리 실패: $e");
    }
  }
}

// provider 정의
final productDetailProvider =
    AsyncNotifierProvider.family<ProductDetailNotifier, ProductDetailDto, int>(
  () => ProductDetailNotifier(),
);
