import '../report_model/product_report_model.dart';

enum ItemReportStatus { PENDING, IN_PROGRESS, RESOLVED }

class ProductReportDto {
  final int id;
  final int itemId;
  final String reason;
  final ItemReportStatus status;
  final String createdAt;
  final bool? hasNext;

  ProductReportDto({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.hasNext = true,
  });

  factory ProductReportDto.fromModel(ProductReportModel model) {
    return ProductReportDto(
      id: model.id,
      itemId: model.itemId,
      reason: model.reason,
      status: ItemReportStatus.values
          .firstWhere((status) => status.name == model.status),
      createdAt: model.createdAt,
    );
  }

  ProductReportDto copyWith({
    int? id,
    int? itemId,
    String? reason,
    ItemReportStatus? status,
    String? createdAt,
  }) {
    return ProductReportDto(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
