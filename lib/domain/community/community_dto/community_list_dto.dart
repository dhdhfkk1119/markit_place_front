import 'dart:convert';

class CommunityListDTO {
  final int id;
  final String title;
  final String topic;
  final String location;
  final String? preview;
  final String? thumbnail;
  final int? likeCount;
  final int? viewCount;
  final String createdAt;
  final int? commentCount;
  final bool? isLiked;

  CommunityListDTO({
    required this.id,
    required this.title,
    required this.topic,
    required this.location,
    this.preview,
    this.thumbnail,
    this.likeCount,
    this.viewCount,
    required this.createdAt,
    this.commentCount,
    this.isLiked,
  });

  factory CommunityListDTO.fromJson(Map<String, dynamic> json) {
    return CommunityListDTO(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      location: json['location'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      preview: json['preview'] as String?,
      thumbnail: json['thumbnail'] as String?,
      likeCount: json['likeCount'] as int?,
      viewCount: json['viewCount'] as int?,
      commentCount: json['commentCount'] as int?,
      isLiked: json['isLiked'] as bool?,
    );
  }
}
