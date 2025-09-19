import 'community_comment.dart';

class CommunityDetail {
  final int id;
  final String title;
  final String content;
  final String writerName; // 작성자 이름
  final String topic;
  final int? likeCount;
  final int? viewCount;
  final String createdAt;
  final String location;
  final List<String>? images; // 이미지 전체 리스트
  final List<CommunityComment>? comments; // 댓글 전체 리스트
  final int? commentCount;

  CommunityDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.writerName,
    required this.topic,
    this.likeCount,
    this.viewCount,
    required this.createdAt,
    required this.location,
    this.images,
    this.comments,
    this.commentCount,
  });

  factory CommunityDetail.fromMap(Map<String, dynamic> json) {
    return CommunityDetail(
      id: (json['id'] ?? 0) as int,
      title: json['title'] as String,
      content: json['content'] as String,
      writerName: json['writerName'] as String,
      topic: json['topic'] as String,
      likeCount: (json['likeCount'] ?? 0) as int,
      viewCount: (json['viewCount'] ?? 0) as int,
      createdAt: json['createdAt'] as String,
      location: json['location'] as String,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((e) => CommunityComment.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      commentCount: (json['commentCount'] ?? 0) as int,
    );
  }
}
