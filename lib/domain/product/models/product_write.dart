class ProductWrite {
  final int itemCategoryId;
  final String title;
  final String content;
  final int price;
  String? tadeLocation;

  ProductWrite(
      {required this.itemCategoryId,
      required this.title,
      required this.content,
      required this.price,
      this.tadeLocation});

  factory ProductWrite.fromJson(Map<String, dynamic> json) {
    return ProductWrite(
      itemCategoryId: json['itemCategoryId'],
      title: json['title'],
      content: json['content'],
      price: json['price'],
      tadeLocation: json['tadeLocation'] ?? '',
    );
  }
}
