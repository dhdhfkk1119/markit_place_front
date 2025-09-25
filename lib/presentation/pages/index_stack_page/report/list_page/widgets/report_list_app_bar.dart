import 'package:flutter/material.dart';

class ReportListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReportListAppBar({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      title: const Text('신고내역', style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }
}
