import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_repository/product_report_repository.dart';
import 'product_report_list_notifier.dart';

class ProductReportNotifier extends AutoDisposeAsyncNotifier<void> {
  final _repository = ProductReportRepository();

  @override
  Future<void> build() async {}

  Future<void> saveProductReport({
    required int itemId,
    required String reason,
  }) async {
    state = const AsyncLoading();

    try {
      await _repository.reportSaveProduct(itemId, reason);
      await ref
          .read(productReportListNotifier.notifier)
          .refreshReportProductList();

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

final productReportProvider =
    AutoDisposeAsyncNotifierProvider<ProductReportNotifier, void>(
        () => ProductReportNotifier());
