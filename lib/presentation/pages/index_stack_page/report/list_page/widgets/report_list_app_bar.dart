import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/report/report_notifier/product_report_list_notifier.dart';

class ReportListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ReportListAppBar({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      title: const Text('신고내역', style: TextStyle(color: Colors.black)),
      centerTitle: true,
      actions: [
        CustomWidget.buildIcon(
          const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            ref.invalidate(productReportListNotifier);
          },
        ),
      ],
    );
  }
}
