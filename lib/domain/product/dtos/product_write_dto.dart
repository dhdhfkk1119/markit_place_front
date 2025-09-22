import '../models/product_list.dart';
import '../models/product_write.dart';

class ProductWriteDto {
  final int itemCategoryId;
  final String title;
  final String content;
  final int price;
  ProductLocation? tradeLocation;

  ProductWriteDto({
    required this.itemCategoryId,
    required this.title,
    required this.content,
    required this.price,
    this.tradeLocation,
  });

  factory ProductWriteDto.fromJson(ProductWrite model) {
    return ProductWriteDto(
      itemCategoryId: model.itemCategoryId,
      title: model.title,
      content: model.content,
      price: model.price,
      tradeLocation: model.tradeLocation, // 추후 추가되면 model.tradeLocation으로 대체
    );
  }
}
