enum ItemReportStatus { PENDING, IN_PROGRESS, RESOLVED }

class ProductReportModel {
  final int id;
  final int itemId;
  final String reason;
  final ItemReportStatus status;
  final String createdAt;
  final String? thumbnailUrl;

  ProductReportModel({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.thumbnailUrl,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      id: (json['id'] as num?)?.toInt() ?? -1,
      itemId: (json['itemId'] as num?)?.toInt() ?? -1,
      reason: (json['reason'] as String?) ?? '',
      status: ItemReportStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['status']?.toString().toLowerCase() ?? ''),
        orElse: () => ItemReportStatus.PENDING,
      ),
      createdAt: (json['createdAt'] as String?) ?? '',
      thumbnailUrl: json['itemThumbnail'] as String?,
    );
  }
}
