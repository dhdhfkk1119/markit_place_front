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
      state = AsyncValue.data(currentProductDetail);

      // 리스트 Notifier에게는 "이 아이템의 좋아요 수가 이걸로 바뀌었어" 라고 알려주기만 함
      ref.read(productListProvider.notifier).updateItemFavoriteStatus(
            itemId,
            status.favoriteCount?.toInt() ?? 0,
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
