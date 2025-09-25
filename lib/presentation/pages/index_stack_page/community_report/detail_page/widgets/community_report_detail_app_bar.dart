import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community_report/report_notifier/community_report_detail_notifier.dart';
import '../../../../../../domain/community_report/report_notifier/community_report_list_notifier.dart';
import '../../../../../../domain/community_report/report_notifier/community_report_notifier.dart';

class CommunityReportDetailAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBack;
  const CommunityReportDetailAppBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ref.invalidate(communityReportDetailProvider);
            },
          ),
        ],
      ),
    );
  }
}
