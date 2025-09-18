class ProductCategory {
  final int id;
  final String name;

  ProductCategory({
    required this.id,
    required this.name,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
