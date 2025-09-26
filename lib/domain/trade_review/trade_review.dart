/// domain/trade_review/trade_review.dart

class TradeReview {
  final int id;
  final String content;
  final String shortContent;
  final int rating;
  final String reviewerLoginId;
  final String createdAt;

  TradeReview({
    required this.id,
    required this.content,
    required this.shortContent,
    required this.rating,
    required this.reviewerLoginId,
    required this.createdAt,
  });

  // JSON 직렬화를 위한 fromJson 팩토리 메서드
  factory TradeReview.fromJson(Map<String, dynamic> json) {
    return TradeReview(
      id: (json['id'] is int) ? json['id'] : (json['id'] as num).toInt(),
      content: json['content'],
      shortContent: json['shortContent'],
      rating: (json['rating'] is int)
          ? json['rating']
          : (json['rating'] as num).toInt(),
      reviewerLoginId: json['reviewerLoginId'],
      createdAt: json['createdAt'],
    );
  }

  // 객체 복사를 위한 copyWith 메서드
  TradeReview copyWith({
    int? id,
    String? content,
    String? shortContent,
    int? rating,
    String? reviewerLoginId,
    String? createdAt,
  }) {
    return TradeReview(
      id: id ?? this.id,
      content: content ?? this.content,
      shortContent: shortContent ?? this.shortContent,
      rating: rating ?? this.rating,
      reviewerLoginId: reviewerLoginId ?? this.reviewerLoginId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
