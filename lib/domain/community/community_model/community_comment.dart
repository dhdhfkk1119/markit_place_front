class CommunityComment {
  final int id;
  final String content;
  final String writerName;
  final int? likeCount;
  final String displayTime;
  final bool isModified;

  CommunityComment({
    required this.id,
    required this.content,
    required this.writerName,
    this.likeCount,
    required this.displayTime,
    required this.isModified,
  });

  factory CommunityComment.fromMap(Map<String, dynamic> json) {
    print('CommunityComment.fromMap received JSON: $json');
    return CommunityComment(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      writerName: json['writerName'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      displayTime: json['displayTime'] as String? ?? '',
      isModified: json['isModified'] as bool? ?? false,
    );
  }
}
