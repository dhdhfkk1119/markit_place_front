import 'package:flutter/material.dart';

class CommunityReportDetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const CommunityReportDetailInfoRow(
      {super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const Spacer(),
          Flexible(
            flex: 0,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
