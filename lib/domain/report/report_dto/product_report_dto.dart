import '../../../presentation/pages/index_stack_page/report/detail_page/report_detail_page.dart';
import '../report_model/product_report_model.dart';

class ProductReportDto {
  final int id;
  final int itemId;
  final String reason;
  final ItemReportStatus status;
  final String createdAt;
  final String? thumbnailUrl;
  final bool? hasNext;

  ProductReportDto({
    required this.id,
    required this.itemId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.thumbnailUrl,
    this.hasNext = true,
  });

  factory ProductReportDto.fromModel(ProductReportModel model) {
    return ProductReportDto(
      id: model.id,
      itemId: model.itemId,
      reason: model.reason,
      status: model.status,
      // status: ItemReportStatus.values
      //    .firstWhere((status) => status.name == model.status),
      createdAt: model.createdAt,
      thumbnailUrl: model.itemThumbnailUrl,
    );
  }

  ProductReportDto copyWith({
    int? id,
    int? itemId,
    String? reason,
    ItemReportStatus? status,
    String? createdAt,
    String? thumbnailUrl,
    bool? hasNext,
  }) {
    return ProductReportDto(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}
