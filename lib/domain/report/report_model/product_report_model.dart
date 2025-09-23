enum ItemReportStatus { PENDING, IN_PROGRESS, RESOLVED }

class ProductReportModel {
  final int id;
  final int itemId;
  final String reason;
  final ItemReportStatus status;
  final String createdAt;

  ProductReportModel({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      id: json['id'],
      itemId: json['itemId'],
      reason: json['reason'],
      status: ItemReportStatus.values
          .firstWhere((status) => status.name == json['status']),
      createdAt: json['createdAt'],
    );
  }
}
