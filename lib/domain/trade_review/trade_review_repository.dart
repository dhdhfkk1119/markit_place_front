/// domain/trade_review/trade_review_repository.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../_core/dtos/api_response_dto.dart';
import '../../_core/utils/my_http.dart';
import 'trade_review.dart';
import 'trade_review_dto.dart';

final logger = Logger();

class TradeReviewRepository {
  final Dio _dio = dio;

  // 리뷰 작성
  Future<TradeReview> createReview(TradeReviewRequestDto requestDto) async {
    try {
      final response = await _dio.post(
        '/api/v1/trade-reviews',
        data: requestDto.toJson(),
      );

      final apiResponse = ApiResponseDto.fromJson(
        response.data,
        fromJsonT: (json) => TradeReview.fromJson(json),
      );

      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!;
      } else {
        throw Exception(apiResponse.error?.message ?? '리뷰 작성에 실패했습니다.');
      }
    } catch (e) {
      logger.e('리뷰 작성 중 오류 발생: $e');
      rethrow;
    }
  }

  // 리뷰 수정
  Future<TradeReview> updateReview(
      int reviewId, TradeReviewRequestDto requestDto) async {
    try {
      final response = await _dio.put(
        '/api/v1/trade-reviews/$reviewId',
        data: requestDto.toJson(),
      );

      final apiResponse = ApiResponseDto.fromJson(
        response.data,
        fromJsonT: (json) => TradeReview.fromJson(json),
      );

      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!;
      } else {
        throw Exception(apiResponse.error?.message ?? '리뷰 수정에 실패했습니다.');
      }
    } catch (e) {
      logger.e('리뷰 $reviewId 수정 중 오류 발생: $e');
      rethrow;
    }
  }

  // 리뷰 삭제
  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await _dio.delete('/api/v1/trade-reviews/$reviewId');

      // 삭제는 반환 데이터가 없으므로 fromJsonT를 전달하지 않습니다.
      final apiResponse = ApiResponseDto.fromJson(response.data);

      if (!apiResponse.success) {
        throw Exception(apiResponse.error?.message ?? '리뷰 삭제에 실패했습니다.');
      }
    } catch (e) {
      logger.e('리뷰 $reviewId 삭제 중 오류 발생: $e');
      rethrow;
    }
  }

  // 리뷰 단일 조회
  Future<TradeReview> getReview(int reviewId) async {
    try {
      final response = await _dio.get('/api/v1/trade-reviews/$reviewId');

      final apiResponse = ApiResponseDto.fromJson(
        response.data,
        fromJsonT: (json) => TradeReview.fromJson(json),
      );

      if (apiResponse.success && apiResponse.response != null) {
        return apiResponse.response!;
      } else {
        throw Exception(apiResponse.error?.message ?? '리뷰 조회에 실패했습니다.');
      }
    } catch (e) {
      logger.e('리뷰 $reviewId 조회 중 오류 발생: $e');
      rethrow;
    }
  }
}
