import 'package:flutter/material.dart';
import 'report_detail_info_row.dart';
import 'report_detail_product_card.dart';
import 'report_detail_status_section.dart';

class ReportDetailBody extends StatelessWidget {
  const ReportDetailBody({super.key});

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, color: Color(0xFFEDEDED));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: const [
        ReportDetailProductCard(),
        SizedBox(height: 16),
        divider,
        ReportDetailInfoRow(label: '신고자', value: '유저2'),
        divider,
        ReportDetailInfoRow(label: '신고 일자', value: '2025.09.23'),
        divider,
        ReportDetailInfoRow(label: '신고 사유', value: '사기 의심 거래'),
        divider,
        ReportDetailStatusSection(statusLabel: '대기중'),
      ],
    );
  }
}
