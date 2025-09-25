import 'package:flutter/material.dart';

class ReportDetailStatusSection extends StatelessWidget {
  final String statusLabel;
  final VoidCallback? onRefresh;

  const ReportDetailStatusSection({
    super.key,
    required this.statusLabel,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('신고 상태',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6E4E),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
