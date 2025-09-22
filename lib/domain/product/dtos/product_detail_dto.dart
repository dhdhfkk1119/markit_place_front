import '../models/product_detail.dart';
import 'product_list_dtos.dart';

class ProductDetailDto {
  final ProductListDto productList;
  final List<String>? imageUrls;

  final int sellerId;
  final String sellerName;
  final String? sellerProfileUrl;
  final String? sellerAddress;
  final double retransactionRate;
  final int itemCategoryId;
  final bool liked;
  final List<String> tags; // Added tags field

  ProductDetailDto({
    required this.productList,
    this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfileUrl,
    this.sellerAddress,
    required this.retransactionRate,
    required this.itemCategoryId,
    required this.liked,
    required this.tags,
  });

  // copyWith 메서드도 tags를 포함하도록 업데이트
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
    List<String>? tags,
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
      tags: tags ?? this.tags,
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
        tradeLocation: null,
        thumbnail: (model.imageUrls != null && model.imageUrls!.isNotEmpty)
            ? model.imageUrls!.first
            : null,
        favoriteCount: model.favoriteCount,
        viewCount: model.viewCount,
        itemCategoryId: model.itemCategoryId,
        tags: model.tags,
      ),
      imageUrls: model.imageUrls ?? [],
      sellerId: model.sellerId,
      sellerName: model.sellerName,
      sellerProfileUrl: model.sellerProfileUrl ?? '',
      sellerAddress: model.sellerAddress ?? '',
      retransactionRate: model.retransactionRate,
      itemCategoryId: model.itemCategoryId,
      liked: model.liked,
      tags: model.tags,
    );
  }
}
