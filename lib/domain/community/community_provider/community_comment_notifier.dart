import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_repository/community_comment_repository.dart';

// 댓글 작성 상태
class CommunityCommentState {
  final bool isAdding; // 댓글 추가 중인지 여부
  final String? errorMessage;
  final bool addSuccess; // 댓글 추가 성공 여부 (UI에서 감지용)

  CommunityCommentState({
    this.isAdding = false,
    this.errorMessage,
    this.addSuccess = false,
  });

  CommunityCommentState copyWith({
    bool? isAdding,
    String? errorMessage, // 이전 에러를 지우기 위해 null 전달 가능
    bool? addSuccess,
  }) {
    return CommunityCommentState(
      isAdding: isAdding ?? this.isAdding,
      errorMessage: errorMessage,
      addSuccess: addSuccess ?? this.addSuccess,
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
      if (kDebugMode) {
        print("CommunityCommentNotifier: Error adding comment - $e");
      }
    }
  }

  void resetAddSuccess() {
    if (state.addSuccess) {
      state = state.copyWith(addSuccess: false, errorMessage: null);
    }
  }
}

// Repository Provider
final communityCommentRepositoryProvider =
    Provider<CommunityCommentRepository>((ref) {
  return CommunityCommentRepository();
});

// Comment Notifier Provider
final communityCommentProvider =
    StateNotifierProvider<CommunityCommentNotifier, CommunityCommentState>(
        (ref) {
  return CommunityCommentNotifier(
      ref.watch(communityCommentRepositoryProvider));
});
