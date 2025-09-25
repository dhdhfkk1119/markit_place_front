/// domain/trade_review/trade_review_repository.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../_core/utils/my_http.dart';
import 'trade_review.dart';
import 'trade_review_dto.dart';

class TradeReviewRepository {
  final Dio _dio = dio; // 중앙에서 관리되는 Dio 인스턴스 사용
  final logger = Logger();

  // 리뷰 작성
  Future<TradeReview> createReview(TradeReviewRequestDto requestDto) async {
    try {
      // URL에서 중복된 /api/ 접두사 제거
      final response = await _dio.post(
        '/v1/trade-reviews',
        data: requestDto.toJson(),
      );

      logger.d('리뷰 생성 응답:', response.data);

      // 인터셉터가 success:false를 걸러주므로, 여기서는 항상 성공 응답이라고 가정합니다.
      // 실제 리뷰 데이터는 'response' 필드에 있습니다.
      return TradeReview.fromJson(response.data['response']);
    } catch (e) {
      logger.e('리뷰 작성 중 오류 발생:', e);
      rethrow; // 오류를 상위로 전파
    }
  }

  // 리뷰 수정
  Future<TradeReview> updateReview(
      int reviewId, TradeReviewRequestDto requestDto) async {
    try {
      // URL에서 중복된 /api/ 접두사 제거
      final response = await _dio.put(
        '/v1/trade-reviews/$reviewId',
        data: requestDto.toJson(),
      );
      return TradeReview.fromJson(response.data['response']);
    } catch (e) {
      logger.e('리뷰 수정 중 오류 발생:', e);
      rethrow;
    }
  }

  // 리뷰 삭제
  Future<void> deleteReview(int reviewId) async {
    try {
      // URL에서 중복된 /api/ 접두사 제거
      await _dio.delete('/v1/trade-reviews/$reviewId');
      // 반환값이 없는 경우, 성공적으로 완료된 것으로 간주합니다.
    } catch (e) {
      logger.e('리뷰 삭제 중 오류 발생:', e);
      rethrow;
    }
  }

  // 리뷰 단일 조회
  Future<TradeReview> getReview(int reviewId) async {
    try {
      // URL에서 중복된 /api/ 접두사 제거
      final response = await _dio.get('/v1/trade-reviews/$reviewId');
      return TradeReview.fromJson(response.data['response']);
    } catch (e) {
      logger.e('리뷰 조회 중 오류 발생:', e);
      rethrow;
    }
  }
}
