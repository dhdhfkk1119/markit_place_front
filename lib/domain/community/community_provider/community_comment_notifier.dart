import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_repository/community_comment_repository.dart';

class CommunityCommentState {
  final bool isAdding;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final bool addSuccess;
  final bool updateSuccess;
  final bool deleteSuccess;

  CommunityCommentState({
    this.isAdding = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.addSuccess = false,
    this.updateSuccess = false,
    this.deleteSuccess = false,
  });

  CommunityCommentState copyWith({
    bool? isAdding,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    bool? addSuccess,
    bool? updateSuccess,
    bool? deleteSuccess,
  }) {
    return CommunityCommentState(
      isAdding: isAdding ?? this.isAdding,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
      addSuccess: addSuccess ?? this.addSuccess,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      deleteSuccess: deleteSuccess ?? this.deleteSuccess,
    );
  }
}

class CommunityCommentNotifier extends StateNotifier<CommunityCommentState> {
  final CommunityCommentRepository _repository;

  CommunityCommentNotifier(this._repository) : super(CommunityCommentState());

  Future<void> addComment({
    required int postId,
    required String content,
  }) async {
    if (content.isEmpty) {
      state = state.copyWith(
          errorMessage: "댓글 내용을 입력해주세요.", addSuccess: false, isAdding: false);
      return;
    }
    state =
        state.copyWith(isAdding: true, errorMessage: null, addSuccess: false);
    try {
      await _repository.createComment(postId: postId, content: content);
      state = state.copyWith(isAdding: false, addSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isAdding: false,
          errorMessage: "댓글 작성 중 오류: ${e.toString()}",
          addSuccess: false);
    }
  }

  Future<void> updateComment({
    required int commentId,
    required String content,
  }) async {
    if (content.isEmpty) {
      state =
          state.copyWith(errorMessage: "수정할 내용을 입력해주세요.", updateSuccess: false);
      return;
    }
    state = state.copyWith(
        isUpdating: true, errorMessage: null, updateSuccess: false);
    try {
      await _repository.updateComment(commentId: commentId, content: content);
      state = state.copyWith(isUpdating: false, updateSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isUpdating: false,
          errorMessage: "댓글 수정 중 오류: ${e.toString()}",
          updateSuccess: false);
    }
  }

  Future<void> deleteComment(int commentId) async {
    state = state.copyWith(
        isDeleting: true, errorMessage: null, deleteSuccess: false);
    try {
      await _repository.deleteComment(commentId: commentId);
      state = state.copyWith(isDeleting: false, deleteSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isDeleting: false,
          errorMessage: "댓글 삭제 중 오류: ${e.toString()}",
          deleteSuccess: false);
    }
  }

  void resetAddSuccess() {
    state = state.copyWith(
      addSuccess: false,
      updateSuccess: false,
      deleteSuccess: false,
      errorMessage: null,
    );
  }
}

final communityCommentRepositoryProvider =
    Provider<CommunityCommentRepository>((ref) {
  return CommunityCommentRepository();
});

final communityCommentProvider =
    StateNotifierProvider<CommunityCommentNotifier, CommunityCommentState>(
        (ref) {
  return CommunityCommentNotifier(
      ref.watch(communityCommentRepositoryProvider));
});
