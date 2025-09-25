import 'package:flutter/material.dart';
import '../../../../../../domain/report/report_dto/product_report_dto.dart';
import '../../../../../../domain/report/report_model/product_report_model.dart';
import 'report_detail_info_row.dart';
import 'report_detail_product_card.dart';
import 'report_detail_status_section.dart';

class ReportDetailBody extends StatelessWidget {
  const ReportDetailBody({
    super.key,
    required this.dto,
    required this.onRefresh,
  });

  final ProductReportDto dto;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final divider = const Divider(height: 1, color: Color(0xFFEDEDED));

    String statusLabel() {
      switch (dto.status) {
        case ItemReportStatus.PENDING:
          return '대기중';
        case ItemReportStatus.IN_PROGRESS:
          return '처리중';
        case ItemReportStatus.RESOLVED:
          return '완료';
        default:
          return '대기중';
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ReportDetailProductCard(
          itemId: dto.itemId,
          onTap: null,
        ),
        const SizedBox(height: 16),
        divider,
        const ReportDetailInfoRow(label: '신고자', value: '-'),
        divider,
        ReportDetailInfoRow(label: '신고 일자', value: dto.createdAt),
        divider,
        ReportDetailInfoRow(label: '신고 사유', value: dto.reason),
        divider,
        ReportDetailStatusSection(
          statusLabel: statusLabel(),
          onRefresh: onRefresh,
        ),
      ],
    );
  }
}
