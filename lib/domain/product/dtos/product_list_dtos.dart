import '../models/product_list.dart';

class ProductListDto {
  final int id;
  final String title;
  final String content;
  final int price;
  final String itemCategoryName;
  final ProductLocation? tradeLocation; // Changed to ProductLocation
  final String? thumbnail;
  final int? favoriteCount;
  final int viewCount;
  final int itemCategoryId;
  final List<String> tags; // Added tags field

  ProductListDto({
    required this.id,
    required this.title,
    required this.content,
    required this.price,
    required this.itemCategoryName,
    this.tradeLocation,
    this.thumbnail,
    this.favoriteCount,
    required this.viewCount,
    required this.itemCategoryId,
    required this.tags,
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
      itemCategoryId: model.itemCategoryId,
      tags: model.tags,
    );
  }

  ProductListDto copyWith({
    int? id,
    String? title,
    String? content,
    int? price,
    String? itemCategoryName,
    ProductLocation? tradeLocation,
    String? thumbnail,
    int? favoriteCount,
    int? viewCount,
    int? itemCategoryId,
    List<String>? tags,
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
      itemCategoryId: itemCategoryId ?? this.itemCategoryId,
      tags: tags ?? this.tags,
    );
  }
}
