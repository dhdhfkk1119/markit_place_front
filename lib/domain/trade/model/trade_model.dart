import '../../trade_review/trade_review.dart';

class TradeListModel {
  final int tradeId;
  final int itemId;
  final String itemTitle;
  final String? itemThumbnail;
  final int price;
  final String tradeStatus;
  final String sellerNickname;
  final bool isReviewed;
  final String tradedAt;
  final TradeReview? review; // 해당 거래의 리뷰 객체 (있을 수도 있음)

  TradeListModel({
    required this.tradeId,
    required this.itemId,
    required this.itemTitle,
    this.itemThumbnail,
    required this.price,
    required this.tradeStatus,
    required this.sellerNickname,
    required this.isReviewed,
    required this.tradedAt,
    this.review,
  });

  factory TradeListModel.fromJson(Map<String, dynamic> json) {
    return TradeListModel(
      tradeId: json['tradeId'] is int
          ? json['tradeId']
          : (json['tradeId'] as num).toInt(),
      itemId: json['itemId'] is int
          ? json['itemId']
          : (json['itemId'] as num).toInt(),
      // PurchaseListItemDTO: title, thumbnailUrl
      itemTitle: json['title'] ?? '',
      itemThumbnail: json['thumbnailUrl'],
      price:
          json['price'] is int ? json['price'] : (json['price'] as num).toInt(),
      tradeStatus: json['tradeStatus'] ?? '',
      // PurchaseListItemDTO: sellerName
      sellerNickname: json['sellerName'] ?? json['sellerNickname'] ?? '',
      isReviewed: json['isReviewed'] ?? (json['reviewId'] != null),
      tradedAt: json['tradedAt'] ?? '',
      // 서버는 목록에서 reviewId/content/rating만 줄 수 있음
      review: (json['reviewId'] != null)
          ? TradeReview.fromJson({
              'id': json['reviewId'],
              'content': json['reviewContent'] ?? '',
              'shortContent': json['reviewContent'] ?? '',
              'rating': json['reviewRating'] ?? 0,
              'reviewerLoginId': '',
              'createdAt': json['tradedAt'] ?? '',
            })
          : (json['review'] != null && json['review'] is Map<String, dynamic>
              ? TradeReview.fromJson(json['review'] as Map<String, dynamic>)
              : null),
    );
  }

  TradeListModel copyWith({
    int? tradeId,
    int? itemId,
    String? itemTitle,
    String? itemThumbnail,
    int? price,
    String? tradeStatus,
    String? sellerNickname,
    bool? isReviewed,
    String? tradedAt,
    TradeReview? review,
  }) {
    return TradeListModel(
      tradeId: tradeId ?? this.tradeId,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemThumbnail: itemThumbnail ?? this.itemThumbnail,
      price: price ?? this.price,
      tradeStatus: tradeStatus ?? this.tradeStatus,
      sellerNickname: sellerNickname ?? this.sellerNickname,
      isReviewed: isReviewed ?? this.isReviewed,
      tradedAt: tradedAt ?? this.tradedAt,
      review: review ?? this.review,
    );
  }
}
