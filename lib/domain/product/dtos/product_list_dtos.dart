import '../models/product_list.dart';

class ProductListDto {
  int id;
  String title;
  String content;
  int price;
  String itemCategoryName;
  String tradeLocation;
  String? thumbnail;
  int? favoriteCount;
  int viewCount;

  ProductListDto({
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

  factory ProductListDto.fromModel(ProductList model) {
    return ProductListDto(
      id: model.id,
      title: model.title,
      content: model.content,
      price: model.price,
      itemCategoryName: model.itemCategoryName,
      tradeLocation: model.tradeLocation,
      thumbnail: model.thumbnail,
      favoriteCount: model.favoriteCount,
      viewCount: model.viewCount,
    );
  }

  ProductListDto copyWith({
    int? id,
    String? title,
    String? content,
    int? price,
    String? itemCategoryName,
    String? tradeLocation,
    String? thumbnail,
    int? favoriteCount,
    int? viewCount,
  }) {
    return ProductListDto(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      price: price ?? this.price,
      itemCategoryName: itemCategoryName ?? this.itemCategoryName,
      tradeLocation: tradeLocation ?? this.tradeLocation,
      thumbnail: thumbnail ?? this.thumbnail,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
