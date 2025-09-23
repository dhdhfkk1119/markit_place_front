class ProductFavorite {
  final int itemId;
  final String title;
  final String thumbnailUrl;
  final int price;
  final String tradeLocation;
  final int favoriteCount;

  ProductFavorite({
    required this.itemId,
    required this.title,
    required this.thumbnailUrl,
    required this.price,
    required this.tradeLocation,
    required this.favoriteCount,
  });

  factory ProductFavorite.fromJson(Map<String, dynamic> json) {
    return ProductFavorite(
      itemId: json['itemId'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      price: json['price'],
      tradeLocation: json['tradeLocation'],
      favoriteCount: json['favoriteCount'],
    );
  }
}
