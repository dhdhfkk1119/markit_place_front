import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_repository/community_comment_like_repository.dart';
import '../community_dto/community_comment_like_dot.dart';

class CommunityCommentLikeNotifier extends ChangeNotifier {
  final CommunityCommentLikeRepository _likeRepository = CommunityCommentLikeRepository();

  // 댓글 ID를 키로, 좋아요 상태를 값으로 저장하는 Map
  final Map<int, CommunityCommentLikeDTO> _likeState = {};

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 특정 댓글의 좋아요 상태를 가져오는 메서드
  CommunityCommentLikeDTO? getLikeState(int commentId) {
    return _likeState[commentId];
  }

  // 좋아요 상태를 토글하는 메서드
  Future<void> toggleLike(int commentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final CommunityCommentLikeDTO updatedState = await _likeRepository.toggleLike(commentId);
      _likeState[commentId] = updatedState;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error toggling like: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 초기 상태를 로드하는 메서드 (UI에 표시하기 전에 사용)
  Future<void> loadInitialLikeState(int commentId) async {
    try {
      final CommunityCommentLikeDTO initialState = await _likeRepository.getLikeStatus(commentId);
      _likeState[commentId] = initialState;
      notifyListeners();
    } catch (e) {
      // 초기 로딩 실패 시 에러 처리
      debugPrint("Error loading initial like state: $e");
    }
  }
}

final communityCommentLikeProvider = ChangeNotifierProvider<CommunityCommentLikeNotifier>(
        (ref) => CommunityCommentLikeNotifier());