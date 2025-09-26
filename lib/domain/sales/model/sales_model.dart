enum TradeStatus { ON_SALE, PENDING, SOLD }

class SalesModel {
  final int id;
  final String title;
  final int price;
  final String? thumbnailUrl;
  final String createdAt;
  final String statusLabel;
  final TradeStatus status;

  SalesModel({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.statusLabel,
    required this.status,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    print("json으로 변환된 판매 목록 : ${json}");
    return SalesModel(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      thumbnailUrl: json['thumbnailUrl'],
      createdAt: json['createdAt'],
      statusLabel: json['statusLabel'] ?? '',
      status: TradeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
    );
  }
}
