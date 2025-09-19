import 'package:flutter/material.dart';
import '../../../../../_core/constants/custom_widget.dart';

class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

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
        title: CustomWidget.buildTitle('관심 목록'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            15,
                (index) => _buildFavoriteItem(
              title: '관심 상품 ${index + 1}',
              location: '전포동',
              price: '${(index + 1) * 3000} 원',
              likes: index * 2 + 5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteItem({
    required String title,
    required String location,
    required String price,
    required int likes,
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
                  location,
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                CustomWidget.buildTitle(
                  price,
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.favorite, size: 20, color: Colors.red),
              CustomWidget.buildTitle(
                likes.toString(),
                size: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}