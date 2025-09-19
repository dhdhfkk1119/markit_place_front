class CommunityCommentLikeDTO {
  final bool liked;
  final int likeCount;

  CommunityCommentLikeDTO({
    required this.liked,
    required this.likeCount,
  });

  factory CommunityCommentLikeDTO.fromJson(Map<String, dynamic> json) {
    return CommunityCommentLikeDTO(
      liked: json["liked"] as bool,
      likeCount: json["likeCount"] as int,
    );
  }
}
