///==============================================================================
///
///                  거래 리뷰(TradeReview) 기능 사용 가이드 (for UI 개발자)
///
///==============================================================================
/*
 안녕하세요! 거래 리뷰(구매후기)의 작성, 수정, 삭제, 조회 기능을 위한 도메인 로직입니다.
 UI 개발 시 아래 가이드를 참고하여 `trade_review_provider.dart`를 사용해 주세요.

 ----------------------------------------------------------------------------

 ### 1. 핵심 Provider 소개

 리뷰 기능을 사용할 때는 아래의 `NotifierProvider` 하나만 사용하시면 됩니다.

 - **Provider:** `tradeReviewProvider`
 - **타입:** `NotifierProvider<TradeReviewNotifier, AsyncValue<TradeReview?>>`
 - **설명:**
   - 단일 거래 리뷰의 상태를 관리합니다.
   - 상태는 `AsyncValue`로 래핑되어 있어 **로딩, 데이터, 에러** 상태를 쉽게 처리할 수 있습니다.
   - `data` 상태일 때, 내부에 `TradeReview` 객체가 있거나(조회/생성/수정 성공 시), `null`일 수 있습니다(초기 상태 또는 삭제 성공 시).

 ----------------------------------------------------------------------------

 ### 2. 상태(State) 감지 및 UI 처리 방법

 UI에서는 `ref.watch`를 사용하여 `tradeReviewProvider`의 상태 변화를 감지하고,
 `when`을 사용하여 각 상태에 맞는 위젯을 렌더링해야 합니다.

 **기본 사용 예시:**

 ```dart
 // ConsumerWidget 또는 ConsumerStatefulWidget 내부의 build 메서드에서
 final reviewState = ref.watch(tradeReviewProvider);

 return reviewState.when(
   // 데이터가 성공적으로 로드되었을 때
   data: (review) {
     if (review == null) {
       // 아직 조회 전이거나, 삭제 성공 후의 상태
       return Text('리뷰 데이터가 없습니다.');
     }
     // 조회/생성/수정된 리뷰 데이터를 사용하여 UI를 구성
     return Column(
       children: [
         Text('리뷰 내용: ${review.content}'),
         Text('평점: ${review.rating}'),
       ],
     );
   },
   // 로딩 중일 때
   loading: () => const Center(child: CircularProgressIndicator()),
   // 에러가 발생했을 때
   error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
 );
 ```

 ----------------------------------------------------------------------------

 ### 3. 사용 가능한 기능 (Action Methods)

 리뷰를 생성, 수정, 삭제, 조회하는 기능은 `ref.read(tradeReviewProvider.notifier)`를 통해 호출할 수 있습니다.

 #### A. 리뷰 작성

 - **메서드:** `createReview(TradeReviewRequestDto requestDto)`
 - **설명:** 새로운 리뷰를 서버에 생성합니다.
 - **사용법:**
   ```dart
   // UI에서 사용자가 입력한 값으로 DTO 생성
   final newReviewDto = TradeReviewRequestDto(
     tradeId: 123, // 실제 거래 ID
     content: '상품 정말 마음에 들어요!',
     rating: 5,
   );
   // Notifier의 메서드 호출
   await ref.read(tradeReviewProvider.notifier).createReview(newReviewDto);
   ```
 - **결과:** 호출 즉시 `tradeReviewProvider`의 상태가 `AsyncLoading`으로 변경되고, 성공 시 `AsyncData`와 함께 생성된 `TradeReview` 객체가 상태로 업데이트됩니다. 실패 시 `AsyncError`로 변경됩니다.

 #### B. 리뷰 단일 조회

 - **메서드:** `getReview(int reviewId)`
 - **설명:** 특정 ID의 리뷰 정보를 가져옵니다.
 - **사용법:**
   ```dart
   await ref.read(tradeReviewProvider.notifier).getReview(45); // 조회할 리뷰 ID
   ```
 - **결과:** `createReview`와 동일하게 로딩 후 성공/실패 상태로 업데이트됩니다.

 #### C. 리뷰 수정

 - **메서드:** `updateReview(int reviewId, TradeReviewRequestDto requestDto)`
 - **설명:** 기존 리뷰를 수정합니다.
 - **사용법:**
   ```dart
   final updatedDto = TradeReviewRequestDto(
     tradeId: 123, // DTO 구조상 필요. 실제로는 reviewId로 대상을 찾음
     content: '내용을 수정합니다.',
     rating: 4,
   );
   await ref.read(tradeReviewProvider.notifier).updateReview(45, updatedDto); // 수정할 리뷰 ID
   ```
 - **결과:** `createReview`와 동일하게 로딩 후 성공/실패 상태로 업데이트됩니다.

 #### D. 리뷰 삭제

 - **메서드:** `deleteReview(int reviewId)`
 - **설명:** 특정 ID의 리뷰를 삭제합니다.
 - **사용법:**
   ```dart
   await ref.read(tradeReviewProvider.notifier).deleteReview(45); // 삭제할 리뷰 ID
   ```
 - **결과:** 호출 즉시 `AsyncLoading`으로 변경되고, 성공 시 `AsyncData(null)` 상태가 되어 UI가 초기 상태로 돌아갑니다.
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'trade_review.dart';
import 'trade_review_dto.dart';
import 'trade_review_repository.dart';

final logger = Logger();

// Repository Provider
final tradeReviewRepositoryProvider = Provider<TradeReviewRepository>((ref) {
  return TradeReviewRepository();
});

// Notifier Provider
// 단일 리뷰의 상태를 관리합니다 (생성/수정/조회 결과 또는 null).
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
    // 초기 상태는 데이터가 없는 성공 상태입니다.
    return const AsyncData(null);
  }

  // 리뷰 생성
  Future<void> createReview(TradeReviewRequestDto requestDto) async {
    state = const AsyncLoading();
    try {
      final review = await _repository.createReview(requestDto);
      state = AsyncData(review);
      logger.i('리뷰 생성 성공: ${review.id}');
    } catch (e, stackTrace) {
      logger.e('리뷰 생성 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }

  // 리뷰 수정
  Future<void> updateReview(
      int reviewId, TradeReviewRequestDto requestDto) async {
    state = const AsyncLoading();
    try {
      final review = await _repository.updateReview(reviewId, requestDto);
      state = AsyncData(review);
      logger.i('리뷰 수정 성공: ${review.id}');
    } catch (e, stackTrace) {
      logger.e('리뷰 수정 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }

  // 리뷰 삭제
  Future<void> deleteReview(int reviewId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteReview(reviewId);
      state = const AsyncData(null); // 삭제 성공 후 상태를 초기화합니다.
      logger.i('리뷰 삭제 성공: $reviewId');
    } catch (e, stackTrace) {
      logger.e('리뷰 삭제 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }

  // 리뷰 단일 조회
  Future<void> getReview(int reviewId) async {
    state = const AsyncLoading();
    try {
      final review = await _repository.getReview(reviewId);
      state = AsyncData(review);
      logger.i('리뷰 조회 성공: ${review.id}');
    } catch (e, stackTrace) {
      logger.e('리뷰 조회 실패', e, stackTrace);
      state = AsyncError(e, stackTrace);
    }
  }
}
