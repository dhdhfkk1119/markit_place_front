import 'package:flutter/material.dart';

class ReportDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;

  const ReportDetailAppBar({super.key, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("신고 내역"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBack,
      ),
    );
  }
}
