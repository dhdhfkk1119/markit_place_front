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

// Notifier Provider
final tradeReviewProvider =
    NotifierProvider<TradeReviewNotifier, AsyncValue<TradeReview?>>(() {
  return TradeReviewNotifier();
});

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
