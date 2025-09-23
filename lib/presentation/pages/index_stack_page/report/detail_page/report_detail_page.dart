import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/report_detail_app_bar.dart';
import 'widgets/report_detail_body.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ReportDetailAppBar(onBack: null),
      body: ReportDetailBody(),
    );
  }
}
