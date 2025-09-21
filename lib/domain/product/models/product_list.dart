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
    return ProductList(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      price: json['price'] ?? 0,
      itemCategoryName: json['itemCategoryName'] ?? '',
      tradeLocation: json['tradeLocation'] ?? '',
      thumbnail: json['thumbnail'],
      favoriteCount: json['favoriteCount'] ?? 0,
      viewCount: json['viewCount'],
    );
  }
}
