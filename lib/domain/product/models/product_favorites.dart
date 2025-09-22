class ProductFavorites {
  final int itemId;
  final bool liked;
  final int favoriteCount;

  ProductFavorites({
    required this.itemId,
    required this.liked,
    required this.favoriteCount,
  });

  factory ProductFavorites.fromJson(Map<String, dynamic> json) {
    return ProductFavorites(
      itemId: json['itemId'],
      liked: json['liked'] as bool,
      favoriteCount: (json['favoriteCount'] as num).toInt(),
    );
  }
}
