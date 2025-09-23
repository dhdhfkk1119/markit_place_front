class ProductLocation {
  final double latitude;
  final double longitude;

  ProductLocation({
    required this.latitude,
    required this.longitude,
  });

  factory ProductLocation.fromJson(Map<String, dynamic> json) {
    return ProductLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class ProductListPages {
  final List<ProductList> productList;
  final bool isLastPage; // 마지막 페이지인지 여부

  ProductListPages({
    required this.productList,
    required this.isLastPage,
  });
}

class ProductList {
  final int id;
  final String title;
  final String content;
  final int price;
  final String itemCategoryName;
  final ProductLocation? tradeLocation;
  final String? thumbnail;
  final int favoriteCount;
  final int viewCount;
  final int itemCategoryId;
  final List<String> tags;

  ProductList({
    required this.id,
    required this.title,
    required this.content,
    required this.price,
    required this.itemCategoryName,
    this.tradeLocation,
    this.thumbnail,
    required this.favoriteCount,
    required this.viewCount,
    required this.itemCategoryId,
    required this.tags,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) {
    return ProductList(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      price: (json['price'] as num).toInt(),
      itemCategoryName: json['itemCategoryName'] as String,
      tradeLocation: json['tradeLocation'] != null
          ? ProductLocation.fromJson(
              json['tradeLocation'] as Map<String, dynamic>)
          : null,
      thumbnail: json['thumbnail'] as String?,
      favoriteCount: (json['favoriteCount'] as num).toInt(),
      viewCount: (json['viewCount'] as num).toInt(),
      itemCategoryId: (json['itemCategoryId'] as num).toInt(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
