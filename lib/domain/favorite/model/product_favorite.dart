class ProductFavoriteModel {
  final int itemId;
  final String title;
  final String thumbnailUrl;
  final int price;
  final int favoriteCount;

  ProductFavoriteModel({
    required this.itemId,
    required this.title,
    required this.thumbnailUrl,
    required this.price,
    required this.favoriteCount,
  });

  factory ProductFavoriteModel.fromJson(Map<String, dynamic> json) {
    return ProductFavoriteModel(
      itemId: json['itemId'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      price: json['price'],
      favoriteCount: json['favoriteCount'],
    );
  }
}
