import 'product_list.dart';

class ProductWrite {
  final int itemCategoryId;
  final String title;
  final String content;
  final int price;
  ProductLocation? tradeLocation;

  ProductWrite(
      {required this.itemCategoryId,
      required this.title,
      required this.content,
      required this.price,
      this.tradeLocation});

  factory ProductWrite.fromJson(Map<String, dynamic> json) {
    return ProductWrite(
      itemCategoryId: json['itemCategoryId'],
      title: json['title'],
      content: json['content'],
      price: json['price'],
      tradeLocation: json['tradeLocation'] != null
          ? ProductLocation.fromJson(json['tradeLocation'])
          : null,
    );
  }
}
