class QnaListModel {
  final int id;
  final String question;
  final String memberLoginId;
  final String createdAt;

  QnaListModel({
    required this.id,
    required this.question,
    required this.memberLoginId,
    required this.createdAt,
  });

  factory QnaListModel.fromJson(Map<String, dynamic> json) {
    return QnaListModel(
      id: json['id'],
      question: json['question'],
      memberLoginId: json['memberLoginId'],
      createdAt: json['createdAt'],
    );
  }
}
