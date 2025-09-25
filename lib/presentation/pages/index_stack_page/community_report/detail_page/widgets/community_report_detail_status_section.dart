import 'package:flutter/material.dart';
import '../../../../../../domain/community_report/report_dto/community_report_dto.dart';

class CommunityReportDetailStatusSection extends StatelessWidget {
  final String statusLabel;
  final CommunityReportStatus status;

  const CommunityReportDetailStatusSection({
    super.key,
    required this.statusLabel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            '신고 상태',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CommunityReportStatus status) {
    switch (status) {
      case CommunityReportStatus.PENDING:
        return const Color(0xFFFF9800); // 오렌지
      case CommunityReportStatus.APPROVED:
        return const Color(0xFFFF6E4E); // 빨간색
      case CommunityReportStatus.REJECTED:
        return const Color(0xFF757575); // 회색
    }
  }
}
