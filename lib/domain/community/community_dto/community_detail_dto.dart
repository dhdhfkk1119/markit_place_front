import 'package:markit_place_front/domain/community/community_model/community_comment.dart';
import 'package:markit_place_front/domain/community/community_model/community_detail.dart';
import 'package:markit_place_front/domain/community/community_model/community_list.dart';

class CommunityDetailDto {
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

  CommunityDetailDto({
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

  factory CommunityDetailDto.fromModel(CommunityDetail model) {
    return CommunityDetailDto(
      id: model.id,
      title: model.title,
      content: model.content,
      writerName: model.writerName,
      topic: model.topic,
      createdAt: model.createdAt,
      location: model.location,
      likeCount: model.likeCount ?? 0,
      viewCount: model.viewCount ?? 0,
      images: model.images ?? [],
      comments: model.comments ?? [],
      commentCount: model.commentCount ?? 0,
    );
  }
}
