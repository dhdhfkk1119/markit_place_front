/// domain/trade_review/trade_review_dto.dart

// 리뷰 작성 및 수정을 위한 요청 DTO
class TradeReviewRequestDto {
  final int tradeId;
  final String content;
  final int rating;

  TradeReviewRequestDto({
    required this.tradeId,
    required this.content,
    required this.rating,
  });

  // 객체를 JSON 맵으로 변환
  Map<String, dynamic> toJson() {
    return {
      'tradeId': tradeId,
      'content': content,
      'rating': rating,
    };
  }
}
