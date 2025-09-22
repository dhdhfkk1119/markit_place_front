import '../report_model/product_report_model.dart';

enum ItemReportStatus { PENDING, IN_PROGRESS, RESOLVED }

class ProductReportDto {
  final int id;
  final int itemId;
  final String reason;
  final ItemReportStatus status;
  final String createdAt;

  ProductReportDto({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    required this.createdAt,
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
}
