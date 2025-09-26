import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/report/report_dto/product_report_dto.dart';
import '../../../../../domain/report/report_notifier/product_report_list_notifier.dart';

import '../detail_page/report_detail_page.dart';
import 'widgets/report_list_app_bar.dart';
import 'widgets/report_list_view.dart';

class ReportListPage extends ConsumerWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductReportDto>> state =
        ref.watch(productReportListNotifier);

    Future<void> onRefresh() async {
      ref.invalidate(productReportListNotifier);
      // 필요 시 완료까지 기다리려면 ↓ 사용
      // await ref.read(productReportListNotifier.future).catchError((_) {});
    }

    void onTapItem(ProductReportDto dto) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReportDetailPage(reportId: dto.id)),
      );
    }

    return Scaffold(
      appBar: const ReportListAppBar(),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('에러 발생: $e'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: onRefresh, child: const Text('다시 시도')),
              ],
            ),
          ),
          data: (items) => ReportListView(
            items: items,
            onTapItem: onTapItem,
          ),
        ),
      ),
    );
  }
}
