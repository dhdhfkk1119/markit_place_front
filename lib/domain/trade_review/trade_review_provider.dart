import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'trade_review.dart';
import 'trade_review_dto.dart';
import 'trade_review_repository.dart';
import '../trade/provider/trade_provider.dart';

final logger = Logger();

// Repository Provider
final tradeReviewRepositoryProvider = Provider<TradeReviewRepository>((ref) {
  return TradeReviewRepository();
});

// 단일 리뷰 Notifier Provider
final tradeReviewProvider =
    NotifierProvider<TradeReviewNotifier, AsyncValue<TradeReview?>>(() {
  return TradeReviewNotifier();
});

// 리뷰 목록 상태를 위한 클래스
class ReviewListState {
  final List<TradeReview> reviews;
  final bool isLoading;
  final String? error;

  ReviewListState({
    required this.reviews,
    required this.isLoading,
    this.error,
  });

  ReviewListState copyWith({
    List<TradeReview>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return ReviewListState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error : null, // null이 명시적으로 전달되면 error를 null로 설정
    );
  }

  static ReviewListState initial() {
    return ReviewListState(reviews: [], isLoading: false);
  }
}

// 판매자 리뷰 목록 Provider
final sellerReviewsProvider =
    StateNotifierProvider<SellerReviewsNotifier, ReviewListState>((ref) {
  return SellerReviewsNotifier(ref.watch(tradeReviewRepositoryProvider));
});

// 판매자 최근 리뷰 Provider
final recentReviewsProvider =
    StateNotifierProvider<RecentReviewsNotifier, ReviewListState>((ref) {
  return RecentReviewsNotifier(ref.watch(tradeReviewRepositoryProvider));
});

// 판매자 리뷰 목록 Notifier
class SellerReviewsNotifier extends StateNotifier<ReviewListState> {
  final TradeReviewRepository _repository;

  SellerReviewsNotifier(this._repository) : super(ReviewListState.initial());

  Future<void> loadSellerReviews(int sellerId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final reviews = await _repository.getSellerReviews(sellerId);
      state = state.copyWith(reviews: reviews, isLoading: false);
      logger.i('판매자 리뷰 ${reviews.length}개 로드 성공');
    } catch (e) {
      logger.e('판매자 리뷰 로드 실패', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 판매자 최근 리뷰 Notifier
class RecentReviewsNotifier extends StateNotifier<ReviewListState> {
  final TradeReviewRepository _repository;

  RecentReviewsNotifier(this._repository) : super(ReviewListState.initial());

  Future<void> loadRecentReviews(int sellerId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final reviews = await _repository.getRecentSellerReviews(sellerId);
      state = state.copyWith(reviews: reviews, isLoading: false);
      logger.i('최근 리뷰 ${reviews.length}개 로드 성공');
    } catch (e) {
      logger.e('최근 리뷰 로드 실패', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Notifier
class TradeReviewNotifier extends Notifier<AsyncValue<TradeReview?>> {
  late final TradeReviewRepository _repository;

  @override
  AsyncValue<TradeReview?> build() {
    _repository = ref.watch(tradeReviewRepositoryProvider);
    return const AsyncData(null);
  }

  // 리뷰 생성
  Future<TradeReview> createReview(TradeReviewRequestDto requestDto) async {
    if (state is AsyncLoading) {
      return Future.error('Already loading');
    }
    state = const AsyncLoading();
    try {
      final review = await _repository.createReview(requestDto);
      state = AsyncData(review);
      logger.i('리뷰 생성 성공: ${review.id}');
      await ref
          .read(tradeProvider.notifier)
          .replaceOrInsertTrade(requestDto.tradeId);
      return review;
    } catch (e, stackTrace) {
      logger.e('리뷰 생성 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
      return Future.error(e, stackTrace);
    }
  }

  // 리뷰 수정
  Future<TradeReview> updateReview(
      int reviewId, TradeReviewRequestDto requestDto) async {
    if (state is AsyncLoading) {
      return Future.error('Already loading');
    }
    state = const AsyncLoading();
    try {
      final review = await _repository.updateReview(reviewId, requestDto);
      state = AsyncData(review);
      logger.i('리뷰 수정 성공: ${review.id}');
      await ref
          .read(tradeProvider.notifier)
          .replaceOrInsertTrade(requestDto.tradeId);
      return review;
    } catch (e, stackTrace) {
      logger.e('리뷰 수정 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
      return Future.error(e, stackTrace);
    }
  }

  // 리뷰 삭제
  Future<void> deleteReview(
      {required int tradeId, required int reviewId}) async {
    if (state is AsyncLoading) {
      return Future.error('Already loading');
    }
    state = const AsyncLoading();
    try {
      await _repository.deleteReview(reviewId);
      state = const AsyncData(null);
      logger.i('리뷰 삭제 성공: $reviewId');
      await ref.read(tradeProvider.notifier).replaceOrInsertTrade(tradeId);
    } catch (e, stackTrace) {
      logger.e('리뷰 삭제 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
      // rethrow를 Future.error로 통일합니다.
      return Future.error(e, stackTrace);
    }
  }

  // 리뷰 단일 조회
  Future<void> getReview(int reviewId) async {
    if (state is AsyncLoading) {
      return Future.error('Already loading');
    }
    state = const AsyncLoading();
    try {
      final review = await _repository.getReview(reviewId);
      state = AsyncData(review);
      logger.i('리뷰 조회 성공: ${review.id}');
    } catch (e, stackTrace) {
      logger.e('리뷰 조회 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
      // rethrow를 Future.error로 통일합니다.
      return Future.error(e, stackTrace);
    }
  }
}
