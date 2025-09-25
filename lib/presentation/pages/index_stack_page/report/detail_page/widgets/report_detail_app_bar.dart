import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/report/report_notifier/product_report_detail_notifier.dart';

class ReportDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final reportId;
  final VoidCallback? onBack;

  const ReportDetailAppBar({super.key, this.reportId, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      title: const Text(
        '신고 내역',
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
      ),
      actions: [
        CustomWidget.buildIcon(
          const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            ref.invalidate(productReportDetailProvider(reportId));
          },
        ),
      ],
    );
  }
}
