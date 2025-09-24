import '../community_dto/community_list_dto.dart';

class CommunitySearch {
  final int id;
  final String title;
  final String? preview;
  final String? thumbnail;
  final String topic;
  final int? likeCount;
  final int? viewCount;
  final int? commentCount;
  final String createdAt;
  final String location;

  CommunitySearch({
    required this.id,
    required this.title,
    this.preview,
    this.thumbnail,
    required this.topic,
    this.likeCount,
    this.viewCount,
    this.commentCount,
    required this.createdAt,
    required this.location,
  });


  factory CommunitySearch.fromDto(CommunityListDTO dto) {
    return CommunitySearch(
      id: dto.id,
      title: dto.title,
      preview: dto.preview,
      thumbnail: dto.thumbnail,
      topic: dto.topic,
      likeCount: dto.likeCount,
      viewCount: dto.viewCount,
      commentCount: dto.commentCount,
      createdAt: dto.createdAt,
      location: dto.location,
    );
  }
}