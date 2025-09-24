import 'product_list.dart';

class ProductDetail {
  final int id;
  final int itemCategoryId;
  final String title;
  final String content;
  final int price;
  final ProductLocation? tradeLocation; // Changed to ProductLocation
  final List<String>? imageUrls; // Corresponds to `base64Images`
  final int favoriteCount;

  final int sellerId;
  final String sellerName;
  final String? sellerProfileUrl;
  final String? sellerAddress; // Nullable
  final double retransactionRate;
  final int viewCount;
  final bool liked;
  final List<String> tags; // Added tags field
  final String? status;

  ProductDetail({
    required this.id,
    required this.itemCategoryId,
    required this.title,
    required this.content,
    required this.price,
    this.tradeLocation,
    this.imageUrls,
    required this.favoriteCount,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfileUrl,
    this.sellerAddress,
    required this.retransactionRate,
    required this.viewCount,
    required this.liked,
    required this.tags,
    this.status,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: (json['id'] as num).toInt(),
      itemCategoryId: (json['itemCategoryId'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      price: (json['price'] as num).toInt(),
      tradeLocation: json['tradeLocation'] != null
          ? ProductLocation.fromJson(json['tradeLocation'])
          : null,
      imageUrls: json['base64Images'] != null
          ? List<String>.from(json['base64Images'])
          : [],
      favoriteCount: (json['favoriteCount'] as num).toInt(),
      sellerId: (json['sellerId'] as num).toInt(),
      sellerName: json['sellerName'] as String,
      sellerProfileUrl: json['sellerProfileUrl'] as String?,
      sellerAddress: json['sellerAddress'] as String?,
      retransactionRate: (json['retransactionRate'] as num).toDouble(),
      viewCount: (json['viewCount'] as num).toInt(),
      liked: json['liked'] as bool,
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] as String?,
    );
  }
}
