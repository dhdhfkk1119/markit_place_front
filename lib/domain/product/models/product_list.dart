class ProductList {
  int id;
  String title;
  String content;
  int price;
  String itemCategoryName;
  String tradeLocation;
  String? thumbnail;
  int? favoriteCount;
  int viewCount;

  ProductList({
    required this.id,
    required this.title,
    required this.content,
    required this.price,
    required this.itemCategoryName,
    required this.tradeLocation,
    this.thumbnail,
    this.favoriteCount,
    required this.viewCount,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) {
    String locationString;
    final category = json['itemCategoryName']?.toString() ?? '카테고리 없음';

    if (json['tradeLocation'] is Map<String, dynamic>) {
      final locationMap = json['tradeLocation'];
      final latitude = locationMap['latitude']?.toString() ?? '위도 정보 없음';
      final longitude = locationMap['longitude']?.toString() ?? '경도 정보 없음';

      // TODO -> Geocoding으로 위치 표시
    }

    return ProductList(
      id: json['id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      content: json['content'] ?? '내용 없음',
      price: json['price'] ?? 0,
      itemCategoryName: category,
      tradeLocation: "locationString",
      favoriteCount: json['favoriteCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
    );
  }
}
