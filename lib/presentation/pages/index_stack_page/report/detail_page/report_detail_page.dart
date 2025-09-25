import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/report/report_notifier/product_report_detail_notifier.dart';
import 'widgets/report_detail_app_bar.dart';
import 'widgets/report_detail_body.dart';

class ReportDetailPage extends ConsumerWidget {
  final int reportId;
  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productReportDetailProvider(reportId));
    void onRefresh() => ref.invalidate(productReportDetailProvider(reportId));

    return state.when(
      loading: () => const Scaffold(
        appBar: ReportDetailAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: const ReportDetailAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onRefresh, child: const Text('다시 시도')),
            ],
          ),
        ),
      ),
      data: (dto) => Scaffold(
        appBar: ReportDetailAppBar(
          onBack: () => Navigator.of(context).maybePop(),
          reportId: reportId,
        ),
        body: ReportDetailBody(
          dto: dto,
          onRefresh: onRefresh,
        ),
      ),
    );
  }
}
