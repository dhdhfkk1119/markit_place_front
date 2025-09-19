import 'package:flutter/material.dart';
import '../../../../../_core/constants/custom_widget.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomWidget.buildIcon(
          const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle('판매 내역'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            20, // 더미 데이터 20개 생성
                (index) => _buildSaleItem(
              title: '판매 상품 ${index + 1}',
              status: index % 3 == 0 ? '판매중' : '판매완료',
              price: '${(index + 1) * 1000} 원',
              date: '2025.08.${15 + index}',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaleItem({
    required String title,
    required String status,
    required String price,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(
                  title,
                  size: 16,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  price,
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  status,
                  size: 12,
                  color: status == '판매중' ? Colors.green : Colors.red,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  date,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}