import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_dto/community_detail_dto.dart';
import '../community_model/community_comment.dart'; // CommunityComment 임포트 추가
import '../community_model/community_detail.dart';
import '../community_repository/community_detail_repository.dart';

// 정렬 기준 Enum 정의
enum CommentSortOrder {
  registration, // 등록순
  latest, // 최신순
}

class CommunityDetailState {
  final CommunityDetailDto? communityDetail;
  final bool isLoading;
  final String? errorMessage;
  final bool isLiking;
  final CommentSortOrder currentSortOrder;

  CommunityDetailState({
    this.communityDetail,
    this.isLoading = false,
    this.errorMessage,
    this.isLiking = false,
    this.currentSortOrder = CommentSortOrder.registration,
  });

  CommunityDetailState copyWith({
    CommunityDetailDto? communityDetail,
    bool? isLoading,
    String? errorMessage,
    bool? isLiking,
    CommentSortOrder? currentSortOrder,
  }) {
    return CommunityDetailState(
      communityDetail: communityDetail ?? this.communityDetail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isLiking: isLiking ?? this.isLiking,
      currentSortOrder: currentSortOrder ?? this.currentSortOrder,
    );
  }
}

class CommunityDetailNotifier extends ChangeNotifier {
  late final CommunityDetailRepository _repository;
  final int postId;
  late CommunityDetailState state;

  // 원본 댓글 리스트를 저장할 변수 (정렬되지 않은 초기 상태)
  List<CommunityComment> _originalComments = [];

  CommunityDetailNotifier({required this.postId}) {
    _repository = CommunityDetailRepository();
    state =
        CommunityDetailState(currentSortOrder: CommentSortOrder.registration);
    getCommunityDetailInfo();
  }

  Future<void> getCommunityDetailInfo() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await _repository.communityDetail(postId: postId);
      final Map<String, dynamic> responseData =
          response as Map<String, dynamic>;
      final communityDetailModel = CommunityDetail.fromMap(responseData);

      // 원본 댓글 리스트 저장 및 초기 정렬 (등록순)
      _originalComments = List.from(communityDetailModel.comments ?? []);

      final sortedComments =
          _sortComments(_originalComments, state.currentSortOrder);
      final dto = CommunityDetailDto.fromModel(communityDetailModel)
          .copyWith(comments: sortedComments);

      state = state.copyWith(communityDetail: dto, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    } finally {
      notifyListeners();
    }
  }

  // 댓글 정렬 메소드 추가
  void sortComments(CommentSortOrder newOrder) {
    if (state.communityDetail == null) return;
    if (state.currentSortOrder == newOrder &&
        state.communityDetail!.comments!.isNotEmpty) return;

    final sortedComments =
        _sortComments(List.from(_originalComments), newOrder);

    state = state.copyWith(
      communityDetail:
          state.communityDetail!.copyWith(comments: sortedComments),
      currentSortOrder: newOrder,
    );
    notifyListeners();
  }

  // 내부 정렬 로직 헬퍼 메소드
  List<CommunityComment> _sortComments(
      List<CommunityComment> comments, CommentSortOrder order) {
    try {
      if (order == CommentSortOrder.latest) {
        comments.sort((a, b) => DateTime.parse(b.createdAt)
            .compareTo(DateTime.parse(a.createdAt))); // 최신순 (내림차순)
      } else {
        // CommentSortOrder.registration (기본)
        comments.sort((a, b) => DateTime.parse(a.createdAt)
            .compareTo(DateTime.parse(b.createdAt))); // 등록순 (오름차순)
      }
    } catch (e) {
      if (kDebugMode) {
        print("댓글 정렬 중 날짜 파싱 오류: $e");
      }
    }
    return comments;
  }

  Future<void> toggleLike() async {
    if (state.communityDetail == null || state.isLiking) {
      return;
    }

    state = state.copyWith(isLiking: true);
    notifyListeners();

    CommunityDetailDto originalDetail = state.communityDetail!;
    CommunityDetailDto optimisticDetail = originalDetail.copyWith(
      isLiked: !originalDetail.isLiked,
      likeCount: originalDetail.isLiked
          ? (originalDetail.likeCount ?? 1) - 1
          : (originalDetail.likeCount ?? 0) + 1,
    );

    state = state.copyWith(communityDetail: optimisticDetail);
    notifyListeners();

    try {
      await _repository.toggleLike(postId: postId);
      state = state.copyWith(isLiking: false);
    } catch (e) {
      state = state.copyWith(
        communityDetail: originalDetail,
        errorMessage: "좋아요 처리에 실패했습니다: ${e.toString()}",
        isLiking: false,
      );
    } finally {
      notifyListeners();
    }
  }

  CommunityDetailDto? get communityDetail => state.communityDetail;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get isLiking => state.isLiking;
  CommentSortOrder get currentSortOrder => state.currentSortOrder;
}

final communityDetailProvider =
    ChangeNotifierProvider.family<CommunityDetailNotifier, int>(
  (ref, postId) => CommunityDetailNotifier(postId: postId),
);
