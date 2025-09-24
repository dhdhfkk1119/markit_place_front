class NoticeListModel {
  final int id;
  final String title;
  final String content;
  final String createdAt;

  NoticeListModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NoticeListModel.fromJson(Map<String, dynamic> json) {
    return NoticeListModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
