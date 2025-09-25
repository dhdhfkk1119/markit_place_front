import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../domain/trade_review/trade_review.dart';
import '../../../../../domain/trade_review/trade_review_provider.dart';

final _logger = Logger();

class ReviewList extends ConsumerStatefulWidget {
  const ReviewList({super.key});

  @override
  ConsumerState<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends ConsumerState<ReviewList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadReviews());
  }

  Future<void> _loadReviews() async {
    try {
      final userId = ref.read(authNotifierProvider).user?.memberId;
      if (userId != null) {
        await ref
            .read(sellerReviewsProvider.notifier)
            .loadSellerReviews(userId);
      }
    } catch (e) {
      _logger.e("리뷰 로딩 실패: $e");
    }
  }

  Widget _buildReviewComment(TradeReview review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 별점 표시
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: index < review.rating ? Colors.amber : Colors.grey,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(review.content,
              size: 14,
              color: const Color(0xFF333333),
              weight: FontWeight.normal),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomWidget.buildTitle(review.reviewerLoginId,
                  size: 12, color: Colors.grey),
              CustomWidget.buildTitle(_formatDate(review.createdAt),
                  size: 12, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(sellerReviewsProvider);
    final reviews = reviewState.reviews;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle("받은 거래 후기", size: 18),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: reviewState.isLoading && reviews.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : reviews.isEmpty
                ? const Center(
                    child: Text(
                      "아직 받은 거래 후기가 없습니다.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewComment(reviews[index]);
                    },
                  ),
      ),
    );
  }
}
