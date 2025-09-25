import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/community_report/report_notifier/community_report_detail_notifier.dart';
import 'widgets/community_report_detail_app_bar.dart';
import 'widgets/community_report_detail_body.dart';

class CommunityReportDetailPage extends ConsumerWidget {
  final int reportId;

  const CommunityReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(communityReportDetailProvider(reportId));

    return Scaffold(
      appBar: const CommunityReportDetailAppBar(),
      body: reportAsync.when(
        data: (report) => CommunityReportDetailBody(report: report),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다\n$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(communityReportDetailProvider(reportId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
