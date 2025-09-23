import 'package:flutter/material.dart';

class ReportDetailBody extends StatelessWidget {
  final String productTitle;
  final int price;
  final String location;
  final String reporterName;
  final String createdAt;
  final String reason;
  final String status;

  const ReportDetailBody({
    super.key,
    required this.productTitle,
    required this.price,
    required this.location,
    required this.reporterName,
    required this.createdAt,
    required this.reason,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [],
    );
  }
}

/// 상품 카드
