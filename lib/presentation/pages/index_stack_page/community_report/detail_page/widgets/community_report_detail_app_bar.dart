import 'package:flutter/material.dart';

class CommunityReportDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBack;
  const CommunityReportDetailAppBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
