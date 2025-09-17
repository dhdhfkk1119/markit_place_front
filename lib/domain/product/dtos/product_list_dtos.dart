import 'package:markit_place_front/domain/product/models/product_list.dart';

class ProductListDto {
  int id;
  String title;
  String content;
  int price;
  String itemCategoryName;
  String tradeLocation;
  String? thumbnail;
  int? favoriteCount;

  ProductListDto(
      {required this.id,
      required this.title,
      required this.content,
      required this.price,
      required this.itemCategoryName,
      required this.tradeLocation,
      this.thumbnail,
      this.favoriteCount});

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
    );
  }
}
