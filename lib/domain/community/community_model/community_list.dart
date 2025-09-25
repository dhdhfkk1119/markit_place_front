// domain/community/community_model/community_list.dart
import '../community_dto/community_list_dto.dart';

class CommunityList {
  final int id;
  final String title;
  final String topic;
  final String location;
  final String? preview;
  final String? thumbnail;
  final int likeCount;
  final int viewCount;
  final String createdAt;
  final int commentCount;
  final bool isLiked;

  CommunityList({
    required this.id,
    required this.title,
    required this.topic,
    required this.location,
    this.preview,
    this.thumbnail,
    required this.likeCount,
    required this.viewCount,
    required this.createdAt,
    required this.commentCount,
    required this.isLiked,
  });

  factory CommunityList.fromModel(CommunityListDTO dto) {
    return CommunityList(
      id: dto.id,
      title: dto.title,
      topic: dto.topic,
      location: dto.location,
      preview: dto.preview,
      thumbnail: dto.thumbnail,
      likeCount: dto.likeCount ?? 0,
      viewCount: dto.viewCount ?? 0,
      createdAt: dto.createdAt,
      commentCount: dto.commentCount ?? 0,
      isLiked: dto.isLiked ?? false,
    );
  }

  CommunityList copyWith({
    int? id,
    String? title,
    String? topic,
    String? location,
    String? preview,
    String? thumbnail,
    int? likeCount,
    int? viewCount,
    String? createdAt,
    int? commentCount,
    bool? isLiked,
  }) {
    return CommunityList(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      location: location ?? this.location,
      preview: preview ?? this.preview,
      thumbnail: thumbnail ?? this.thumbnail,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}