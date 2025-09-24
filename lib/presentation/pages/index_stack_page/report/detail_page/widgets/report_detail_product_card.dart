import 'package:flutter/material.dart';

class ReportDetailProductCard extends StatelessWidget {
  const ReportDetailProductCard({
    super.key,
    required this.itemId,
    this.onTap,
    this.title,
    this.priceLabel,
    this.locationLabel,
    this.thumbnailUrl,
  });

  final int itemId;
  final VoidCallback? onTap;
  final String? title;
  final String? priceLabel;
  final String? locationLabel;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 34, color: Color(0xFFBDBDBD)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? '상품 ID: $itemId',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                if (priceLabel != null)
                  Text(priceLabel!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                if (locationLabel != null)
                  Text('범일동',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
