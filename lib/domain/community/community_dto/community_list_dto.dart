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
      id: json['id'],
      title: json['title'],
      topic: json['topic'],
      location: json['location'],
      preview: json['preview'],
      thumbnail: json['thumbnail'],
      likeCount: json['likeCount'],
      viewCount: json['viewCount'],
      createdAt: json['createdAt'],
      commentCount: json['commentCount'],
      isLiked: json['isLiked'],
    );
  }
}