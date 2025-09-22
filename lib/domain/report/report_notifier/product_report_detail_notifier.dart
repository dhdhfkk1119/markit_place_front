import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_dto/product_report_dto.dart';
import '../report_model/product_report_model.dart';
import '../report_repository/product_report_repository.dart';

class ProductReportDetailNotifier
    extends FamilyAsyncNotifier<ProductReportDto, int> {
  final ProductReportRepository _reportRepository = ProductReportRepository();

  @override
  Future<ProductReportDto> build(int reportId) async {
    try {
      final response = await _reportRepository.reportDetail(reportId: reportId);
      final productReport = ProductReportModel.fromJson(response);
      final dto = ProductReportDto.fromModel(productReport);
      return dto;
    } catch (e) {
      throw Exception("서버를 연결할수없습니다");
    }
  }
}

final productReportDetailProvider = AsyncNotifierProvider.family<
    ProductReportDetailNotifier, ProductReportDto, int>(
  () => ProductReportDetailNotifier(),
);
