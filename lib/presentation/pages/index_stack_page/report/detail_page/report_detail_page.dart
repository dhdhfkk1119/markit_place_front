import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/report_detail_app_bar.dart';
import 'widgets/report_detail_body.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReportDetailAppBar(onBack: () => Navigator.pop(context)),
      body: const ReportDetailBody(
        productTitle: '싸도 너무 싸다 아무나 사세요(사기아님)',
        price: 2000,
        location: '범일동',
        reporterName: '유저2',
        createdAt: '2025.09.23',
        reason: '사기 의심 거래',
        status: '대기중',
      ),
    );
  }
}
