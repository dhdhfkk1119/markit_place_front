import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/community/community_provider/community_detail_notifier.dart';
import '../../../../../../domain/community_report/report_dto/community_report_dto.dart';
import 'community_report_detail_card.dart';
import 'community_report_detail_info_row.dart';
import 'community_report_detail_status_section.dart';

class CommunityReportDetailBody extends ConsumerWidget {
  final CommunityReportDto report;

  const CommunityReportDetailBody({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailNotifier = ref.watch(communityDetailProvider(report.postId));

    final dto = detailNotifier.communityDetail;

    if (detailNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dto == null) {
      return const Center(child: Text('게시글 정보를 찾을 수 없습니다.'));
    }

    const divider = Divider(height: 1, color: Color(0xFFEDEDED));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        CommunityReportDetailCard(post: dto),
        const SizedBox(height: 16),
        divider,
        CommunityReportDetailInfoRow(
          label: '게시글 ID',
          value: '${report.postId}',
        ),
        divider,
        CommunityReportDetailInfoRow(
          label: '신고 일자',
          value: _formatDate(report.createdAt),
        ),
        divider,
        CommunityReportDetailInfoRow(
          label: '신고 사유',
          value: report.reason,
        ),
        divider,
        CommunityReportDetailStatusSection(
          statusLabel: _getStatusText(report.status),
          status: report.status,
        ),

        // 상태별 안내 메시지
        const SizedBox(height: 24),
        _buildStatusMessage(report.status),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(CommunityReportStatus status) {
    switch (status) {
      case CommunityReportStatus.PENDING:
        return '검토중';
      case CommunityReportStatus.APPROVED:
        return '승인됨';
      case CommunityReportStatus.REJECTED:
        return '반려됨';
    }
  }

  Widget _buildStatusMessage(CommunityReportStatus status) {
    String message;
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (status) {
      case CommunityReportStatus.PENDING:
        message = '관리자가 검토 중입니다.\n처리까지 시간이 소요될 수 있습니다.';
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        iconData = Icons.schedule;
        break;
      case CommunityReportStatus.APPROVED:
        message = '신고가 승인되어 해당 게시글에 대한\n조치가 완료되었습니다.';
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        iconData = Icons.check_circle;
        break;
      case CommunityReportStatus.REJECTED:
        message = '검토 결과 신고 내용이 반려되었습니다.';
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        iconData = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
