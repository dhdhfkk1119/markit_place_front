import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/product/dtos/product_detail_dto.dart';
import '../../../../../../domain/product/providers/product_detail_notifier.dart';
import '../../../../../../domain/report/report_dto/product_report_dto.dart';
import '../../../../../../domain/report/report_model/product_report_model.dart';
import 'report_detail_info_row.dart';
import 'report_detail_product_card.dart';
import 'report_detail_status_section.dart';

class ReportDetailBody extends ConsumerWidget {
  const ReportDetailBody({
    super.key,
    required this.dto,
    required this.onRefresh,
  });

  final ProductReportDto dto;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final divider = const Divider(height: 1, color: Color(0xFFEDEDED));

    String statusLabel() {
      switch (dto.status) {
        case ItemReportStatus.PENDING:
          return '대기중';
        case ItemReportStatus.IN_PROGRESS:
          return '처리중';
        case ItemReportStatus.BAD_RESOLVED:
          return '제재완료';
        case ItemReportStatus.RESOLVED:
          return '반려';
        default:
          return '대기중';
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ReportDetailProductCard(
            dto: ref.watch(productDetailProvider(dto.itemId))),
        const SizedBox(height: 16),
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
