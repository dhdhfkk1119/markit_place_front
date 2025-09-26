import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/community/community_dto/community_list_dto.dart';
import '../../../../../domain/community_report/report_dto/community_report_dto.dart';
import '../../../../../domain/community_report/report_notifier/community_report_list_notifier.dart';
import '../detail_page/community_report_detail_page.dart';

class CommunityReportListPage extends ConsumerWidget {
  final CommunityListDTO? post;
  const CommunityReportListPage({super.key, this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportListAsync = ref.watch(communityReportListNotifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomWidget.buildIcon(
          const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomWidget.buildTitle('신고 내역'),
        centerTitle: true,
        actions: [
          CustomWidget.buildIcon(
            const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              await ref
                  .read(communityReportListNotifier.notifier)
                  .refreshReportCommunityList();
            },
          ),
        ],
      ),
      body: reportListAsync.when(
        data: (reports) => RefreshIndicator(
          onRefresh: () => ref
              .read(communityReportListNotifier.notifier)
              .refreshReportCommunityList(),
          child: reports.isEmpty
              ? const Center(child: Text('신고 내역이 없습니다.'))
              : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportPost(context, reports[index], ref);
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류가 발생했습니다: $error'),
              ElevatedButton(
                onPressed: () => ref
                    .read(communityReportListNotifier.notifier)
                    .refreshReportCommunityList(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportPost(
      BuildContext context, CommunityReportDto report, ref) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityReportDetailPage(reportId: report.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: _buildImage(post?.thumbnail),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.buildTitle(
                    '게시글 ID: ${report.postId}',
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  CustomWidget.buildTitle(
                    report.reason,
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(report.status),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomWidget.buildTitle(
                    report.createdAt,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildDefaultImage();
    }

    final imageBytes = base64ToBytes(imageUrl);

    if (imageBytes == null) {
      return _buildDefaultImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.report_problem, color: Colors.grey, size: 32),
      ),
    );
  }

  Color _getStatusColor(CommunityReportStatus status) {
    switch (status) {
      case CommunityReportStatus.PENDING:
        return Colors.orange;
      case CommunityReportStatus.APPROVED:
        return Colors.red;
      case CommunityReportStatus.REJECTED:
        return Colors.grey;
    }
  }

  String _getStatusText(CommunityReportStatus status) {
    switch (status) {
      case CommunityReportStatus.PENDING:
        return '대기중';
      case CommunityReportStatus.APPROVED:
        return '승인됨';
      case CommunityReportStatus.REJECTED:
        return '반려됨';
    }
  }
}
