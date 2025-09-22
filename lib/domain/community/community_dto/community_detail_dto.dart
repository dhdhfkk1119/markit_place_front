import '../community_model/community_comment.dart';
import '../community_model/community_detail.dart';

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
  final bool isLiked; // 좋아요 여부 필드 추가

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
    required this.isLiked, // 생성자에 isLiked 추가
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
      isLiked: false, // fromModel 호출 시 기본값 false로 설정 (또는 model에서 가져와야 함)
    );
  }

  CommunityDetailDto copyWith({
    int? id,
    String? title,
    String? content,
    String? writerName,
    String? topic,
    int? likeCount,
    int? viewCount,
    String? createdAt,
    String? location,
    List<String>? images,
    List<CommunityComment>? comments,
    int? commentCount,
    bool? isLiked,
  }) {
    return CommunityDetailDto(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      writerName: writerName ?? this.writerName,
      topic: topic ?? this.topic,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      images: images ?? this.images,
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
