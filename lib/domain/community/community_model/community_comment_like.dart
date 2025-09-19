class CommunityCommentLikeDTO {
  final bool liked;
  final int likeCount;

  CommunityCommentLikeDTO({
    required this.liked,
    required this.likeCount,
  });

  factory CommunityCommentLikeDTO.fromModel(CommunityCommentLikeDTO model) {
    return CommunityCommentLikeDTO(
      liked: model.liked,
      likeCount: model.likeCount,
    );
  }
}
