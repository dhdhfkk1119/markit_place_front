import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../domain/trade_review/trade_review.dart';
import '../../../../../domain/trade_review/trade_review_provider.dart';

final _logger = Logger();

class ReviewListScreen extends ConsumerStatefulWidget {
  final int? sellerId; // 다른 사람의 리뷰를 볼 때 sellerId를 전달받음

  const ReviewListScreen({this.sellerId, Key? key}) : super(key: key);

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> {
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // 컴포넌트가 마운트될 때 리뷰 데이터 로드
    Future.microtask(() {
      _loadReviews();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReviews();
    }
  }

  Future<void> _loadReviews() async {
    try {
      final userId =
          widget.sellerId ?? ref.read(authNotifierProvider).user?.memberId;
      if (userId == null) {
        _logger.e('사용자 ID를 찾을 수 없습니다.');
        return;
      }

      await ref.read(sellerReviewsProvider.notifier).loadSellerReviews(userId);
    } catch (e) {
      _logger.e('리뷰 목록을 불러오는 중 오류가 발생했습니다: $e', e, StackTrace.current);
    }
  }

  Future<void> _loadMoreReviews() async {
    final reviewState = ref.read(sellerReviewsProvider);

    // 이미 로딩 중이거나, 에러가 있거나, 더 이상 불러올 데이터가 없으면 종료
    if (_isLoadingMore || reviewState.isLoading || reviewState.error != null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 페이지네이션 로직이 있다면 여기에 추가
      await Future.delayed(Duration(seconds: 1)); // 로딩 효과를 위한 지연
    } catch (e) {
      _logger.e('추가 리뷰를 불러오는 중 오류가 발생했습니다: $e', e, StackTrace.current);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildReviewItem(TradeReview review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 별점
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: index < review.rating ? Colors.amber : Colors.grey,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 리뷰 내용
          Text(
            review.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
          // 작성자와 날짜를 양쪽 정렬하여 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.reviewerLoginId,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
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
        child: Builder(builder: (context) {
          // 로딩 중이고, 기존에 보여줄 리뷰가 없을 때
          if (reviewState.isLoading && reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러가 발생했고, 기존에 보여줄 리뷰가 없을 때
          if (reviewState.error != null && reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "리뷰 목록을 불러오지 못했습니다",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReviews,
                    child: const Text('재시도'),
                  ),
                ],
              ),
            );
          }

          // 리뷰 데이터가 없을 때
          if (reviews.isEmpty) {
            return const Center(
              child: Text("아직 받은 거래 후기가 없습니다."),
            );
          }

          // 리뷰 목록을 보여줄 때
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reviews.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < reviews.length) {
                return _buildReviewItem(reviews[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        }),
      ),
    );
  }
}
