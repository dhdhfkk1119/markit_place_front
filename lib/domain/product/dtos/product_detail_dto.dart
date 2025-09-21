import '../models/product_detail.dart';
import '../models/product_list.dart';
import 'product_list_dtos.dart';

class ProductDetailDto {
  final ProductListDto productList;
  final List<String>? imageUrls;

  // 판매자 정보
  final int sellerId;
  final String sellerName;
  final String? sellerProfileUrl;
  final String sellerAddress;
  final double retransactionRate;

  final int itemCategoryId;

  final bool liked;

  ProductDetailDto({
    required this.productList,
    this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfileUrl,
    required this.sellerAddress,
    required this.retransactionRate,
    required this.itemCategoryId,
    required this.liked,
  });

  ProductDetailDto copyWith({
    ProductListDto? productList,
    List<String>? imageUrls,
    int? sellerId,
    String? sellerName,
    String? sellerProfileUrl,
    String? sellerAddress,
    double? retransactionRate,
    int? itemCategoryId,
    bool? liked,
  }) {
    return ProductDetailDto(
      productList: productList ?? this.productList,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerProfileUrl: sellerProfileUrl ?? this.sellerProfileUrl,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      retransactionRate: retransactionRate ?? this.retransactionRate,
      itemCategoryId: itemCategoryId ?? this.itemCategoryId,
      liked: liked ?? this.liked,
    );
  }

  factory ProductDetailDto.fromModel(ProductDetail model) {
    return ProductDetailDto(
      productList: ProductListDto(
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
        viewCount: model.viewCount,
      ),
      imageUrls: model.imageUrls ?? [],
      sellerId: model.sellerId,
      sellerName: model.sellerName,
      sellerProfileUrl: model.sellerProfileUrl ?? '',
      sellerAddress: model.sellerAddress,
      retransactionRate: model.retransactionRate,
      itemCategoryId: model.itemCategoryId,
      liked: model.liked, // 초기값 false
    );
  }
}
