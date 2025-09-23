class TradeListModel {
  final int id;
  final int itemId;
  final String title;
  final int price;
  final String thumbnailUrl;
  final String completedAt;
  final String statusLabel;
  final String status;
  final int counterPartyId;
  final String counterPartyName;

  TradeListModel(
      {required this.id,
      required this.itemId,
      required this.title,
      required this.price,
      required this.thumbnailUrl,
      required this.completedAt,
      required this.statusLabel,
      required this.status,
      required this.counterPartyId,
      required this.counterPartyName});

  factory TradeListModel.fromJson(Map<String, dynamic> json) {
    return TradeListModel(
      id: json['id'],
      itemId: json['itemId'],
      title: json['title'],
      price: json['price'],
      thumbnailUrl: json['thumbnailUrl'],
      completedAt: json['completedAt'],
      statusLabel: json['statusLabel'],
      status: json['status'],
      counterPartyId: json['counterPartyId'],
      counterPartyName: json['counterPartyName'],
    );
  }
}
