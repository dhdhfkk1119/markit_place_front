class ProductDetail {
  final int id; // 상품 번호
  final int itemCategoryId;
  final String title;
  final String content;
  final int price;
  final String tradeLocation;
  final List<String>? imageUrls; // 이미지 전체 리스트
  final int favoriteCount;

  // 판매자 정보
  final int sellerId;
  final String sellerName;
  final String? sellerProfileUrl;
  final String sellerAddress;
  final int? retransactionRate;

  ProductDetail({
    required this.id,
    required this.itemCategoryId,
    required this.title,
    required this.content,
    required this.price,
    required this.tradeLocation,
    this.imageUrls,
    required this.favoriteCount,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfileUrl,
    required this.sellerAddress,
    this.retransactionRate,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
        id: json['id'] as int,
        itemCategoryId: json['itemCategoryId'] as int,
        title: json['title'] as String,
        content: json['content'] as String,
        price: json['price'] as int,
        tradeLocation: json['tradeLocation'] as String,
        imageUrls: json['imageUrls'] != null
            ? List<String>.from(json['imageUrls'])
            : [],
        favoriteCount: json['favoriteCount'] ?? 0,
        sellerId: json['sellerId'] as int,
        sellerName: json['sellerName'] as String,
        sellerProfileUrl: json['sellerProfileUrl'] as String?,
        sellerAddress: json['sellerAddress'],
        retransactionRate: json['retransactionRate'] ?? 0);
  }
}
