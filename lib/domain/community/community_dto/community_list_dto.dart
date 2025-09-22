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
  final bool isLiked; // isLiked 필드 추가

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
    this.isLiked = false, // 생성자 기본값 false
  });

  factory CommunityListDTO.fromModel(CommunityList model) {
    return CommunityListDTO(
      id: model.id,
      title: model.title,
      topic: model.topic,
      location: model.location,
      preview: model.preview,
      thumbnail: model.thumbnail,
      likeCount: model.likeCount ?? 0,
      viewCount: model.viewCount ?? 0,
      createdAt: model.createdAt,
      commentCount: model.commentCount ?? 0,
      isLiked: model.isLiked, // 모델의 isLiked 값 사용 (기본값은 모델에서 처리됨)
    );
  }

  CommunityListDTO copyWith({
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
    return CommunityListDTO(
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
