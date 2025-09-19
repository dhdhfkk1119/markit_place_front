import '../models/product_detail.dart';
import '../models/product_list.dart';

class ProductDetailDto {
  final ProductList productList;
  final List<String>? imageUrls;

  // 판매자 정보
  final int sellerId;
  final String sellerName;
  final String? sellerProfileUrl;
  final String sellerAddress;
  final int? retransactionRate;

  ProductDetailDto({
    required this.productList,
    this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfileUrl,
    required this.sellerAddress,
    this.retransactionRate,
  });

  factory ProductDetailDto.fromModel(ProductDetail model) {
    return ProductDetailDto(
      productList: ProductList(
        id: model.id,
        title: model.title,
        content: model.content,
        price: model.price,
        itemCategoryName: "",
        tradeLocation: model.tradeLocation,
        thumbnail: (model.imageUrls != null && model.imageUrls!.isNotEmpty)
            ? model.imageUrls!.first
            : null,
        favoriteCount: model.favoriteCount,
      ),
      imageUrls: model.imageUrls ?? [],
      sellerId: model.sellerId,
      sellerName: model.sellerName,
      sellerProfileUrl: model.sellerProfileUrl ?? '',
      sellerAddress: model.sellerAddress,
      retransactionRate: model.retransactionRate ?? 0,
    );
  }
}
