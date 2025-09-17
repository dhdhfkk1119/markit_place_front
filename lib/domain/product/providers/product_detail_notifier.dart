import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/product/dtos/product_detail_dto.dart';
import 'package:markit_place_front/domain/product/models/product_detail.dart';
import 'package:markit_place_front/domain/product/repository/product_detail_repository.dart';

class ProductDetailState {
  final ProductDetailDto? productDetail;
  final bool isLoading;
  final String? errorMessage;

  ProductDetailState({
    this.productDetail,
    this.isLoading = false,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    ProductDetailDto? productDetail,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductDetailState(
      productDetail: productDetail ?? this.productDetail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductDetailNotifier extends ChangeNotifier {
  final ProductDetailRepository _repository = ProductDetailRepository();
  final int itemId;

  ProductDetailState state = ProductDetailState();

  ProductDetailNotifier({required this.itemId});

  Future<void> getProductDetailInfo() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await _repository.productDetail(itemId: itemId);

      final productDetail = ProductDetail.fromJson(response);
      final dto = ProductDetailDto.fromModel(productDetail);

      state = state.copyWith(productDetail: dto, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    } finally {
      notifyListeners();
    }
  }

  // getter 추가
  ProductDetailDto? get productDetail => state.productDetail;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
}

final productDetailProvider =
    ChangeNotifierProvider.family<ProductDetailNotifier, int>(
  (ref, itemId) => ProductDetailNotifier(itemId: itemId),
);
