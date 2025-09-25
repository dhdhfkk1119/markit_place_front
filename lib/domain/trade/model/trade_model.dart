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
  });

  factory TradeListModel.fromJson(Map<String, dynamic> json) {
    return TradeListModel(
      tradeId: json['tradeId'],
      itemId: json['itemId'],
      itemTitle: json['itemTitle'],
      itemThumbnail: json['itemThumbnail'],
      price: json['price'],
      tradeStatus: json['tradeStatus'],
      sellerNickname: json['sellerNickname'],
      isReviewed: json['isReviewed'],
      tradedAt: json['tradedAt'],
    );
  }
}
