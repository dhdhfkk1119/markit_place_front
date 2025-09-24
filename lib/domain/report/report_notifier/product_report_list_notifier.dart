import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_dto/product_report_dto.dart';
import '../report_repository/product_report_repository.dart';
import '../report_model/product_report_model.dart';

class ProductReportListNotifier extends AsyncNotifier<List<ProductReportDto>> {
  final ProductReportRepository _repository = ProductReportRepository();

  @override
  Future<List<ProductReportDto>> build() async {
    final response = await _repository.reportMyProduct();
    final List<dynamic> content = response['content'] as List<dynamic>;
    return content.map((e) {
      final model = ProductReportModel.fromJson(e as Map<String, dynamic>); // ★
      return ProductReportDto.fromModel(model);
    }).toList();
  }

  Future<void> refreshReportProductList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final productReportListNotifier =
    AsyncNotifierProvider<ProductReportListNotifier, List<ProductReportDto>>(
        () => ProductReportListNotifier());
