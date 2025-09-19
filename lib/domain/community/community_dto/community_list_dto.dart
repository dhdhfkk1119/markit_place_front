import '../community_model/community_list.dart';

class CommunityListDTO {
  final int id;
  final String title;
  final String topic;
  final String location;
  final String preview;
  final String thumbnail;
  final int? likeCount;
  final int? viewCount;
  final String createdAt;
  final int? commentCount;

  CommunityListDTO({
    required this.id,
    required this.title,
    required this.topic,
    required this.location,
    required this.preview,
    required this.thumbnail,
    this.likeCount,
    this.viewCount,
    required this.createdAt,
    this.commentCount,
  });

  factory CommunityListDTO.fromModel(CommunityList dto) {
    return CommunityListDTO(
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
    );
  }
}
