import 'package:flutter/material.dart';

class ReportDetailStatusSection extends StatelessWidget {
  final String statusLabel;
  const ReportDetailStatusSection({super.key, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
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
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          const Text('신고 상태',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
