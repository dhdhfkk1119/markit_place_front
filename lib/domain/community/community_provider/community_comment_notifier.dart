import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/community/community_dto/community_report_dto.dart';
import 'package:markit_place_front/domain/community/community_repository/community_comment_repository.dart';

import '../community_dto/community_comment_dto.dart';

class CommunityCommentModel {
  final List<CommunityCommentDTO> comments;
  final bool isLoading;
  final String? errorMessage;

  CommunityCommentModel({
    required this.comments,
    this.isLoading = false,
    this.errorMessage,
  });

  CommunityCommentModel copyWith({
    List<CommunityCommentDTO>? comments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CommunityCommentModel(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CommunityCommentNotifier extends StateNotifier<CommunityCommentModel> {
  final CommunityCommentRepository _communityCommentRepository;

  CommunityCommentNotifier(this._communityCommentRepository)
      : super(CommunityCommentModel(comments: []));

  Future<void> getCommentsByPostId(int postId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ResponseDTO responseDTO =
          await _communityCommentRepository.getComments(postId);
      if (responseDTO.status == 200) {
        final List<CommunityCommentDTO> comments =
            (responseDTO.data as List<dynamic>)
                .map((e) => CommunityCommentDTO.fromJson(e))
                .toList();
        state = state.copyWith(comments: comments, isLoading: false);
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: responseDTO.message);
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: '댓글을 불러오는데 실패했습니다 : $e');
    }
  }
}
