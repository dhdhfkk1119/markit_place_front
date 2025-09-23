import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_dto/product_report_dto.dart';
import '../report_repository/product_report_repository.dart';

class ProductReportListNotifier extends AsyncNotifier<List<ProductReportDto>> {
  final ProductReportRepository _repository = ProductReportRepository();

  @override
  Future<List<ProductReportDto>> build() async {
    final response = await _repository.reportMyProduct();
    final List<dynamic> content = response['content'];
    return content.map((json) => ProductReportDto.fromModel(json)).toList();
  }

  Future<void> refreshReportProductList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final productReportListNotifier =
    AsyncNotifierProvider<ProductReportListNotifier, List<ProductReportDto>>(
        () => ProductReportListNotifier());
