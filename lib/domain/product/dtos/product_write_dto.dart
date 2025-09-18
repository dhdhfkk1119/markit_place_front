import 'package:markit_place_front/domain/product/models/product_write.dart';

class ProductWriteDto {
  final int itemCategoryId;
  final String title;
  final String content;
  final int price;
  String? tadeLocation;

  ProductWriteDto(
      {required this.itemCategoryId,
      required this.title,
      required this.content,
      required this.price,
      this.tadeLocation});

  factory ProductWriteDto.fromJson(ProductWrite model) {
    return ProductWriteDto(
      itemCategoryId: model.itemCategoryId,
      title: model.title,
      content: model.content,
      price: model.price,
      tadeLocation: model.tadeLocation ?? '',
    );
  }
}
