import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_detail_dto.dart';
import '../models/product_detail.dart';
import '../repository/product_detail_repository.dart';
import 'product_list_notifier.dart';

// FamilyAsyncNotifier를 사용
class ProductDetailNotifier extends FamilyAsyncNotifier<ProductDetailDto, int> {
  final ProductDetailRepository _repository = ProductDetailRepository();

  @override
  Future<ProductDetailDto> build(int itemId) async {
    // itemId는 build의 인자로 바로 받음
    try {
      final response = await _repository.productDetail(itemId: itemId);
      final productDetail = ProductDetail.fromJson(response);
      final dto = ProductDetailDto.fromModel(productDetail);
      return dto;
    } catch (e) {
      throw Exception("서버를 연결할수없습니다");
    }
  }

  Future<void> toggleFavorite(int itemId) async {
    if (state.value == null) return;

    final currentProductDetail = state.value!;

    try {
      final status = await _repository.productFavorite(itemId: itemId);

      final updatedProductDetail = currentProductDetail.copyWith(
        productList: currentProductDetail.productList.copyWith(
          favoriteCount: status.favoriteCount?.toInt() ??
              currentProductDetail.productList.favoriteCount,
        ),
        liked: status.liked,
      );

      state = AsyncValue.data(updatedProductDetail);

      final productListNotifier = ref.read(productListProvider.notifier);
      final currentList = productListNotifier.state.value;

      if (currentList != null) {
        final updatedList = currentList.map((item) {
          if (item.id == itemId) {
            return item.copyWith(
              favoriteCount: status.favoriteCount?.toInt(),
            );
          }
          return item;
        }).toList();

        productListNotifier.state = AsyncValue.data(updatedList);
      }
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
