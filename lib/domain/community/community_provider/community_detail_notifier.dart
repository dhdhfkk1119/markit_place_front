import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/community/community_dto/community_detail_dto.dart';
import 'package:markit_place_front/domain/community/community_model/community_detail.dart';
import 'package:markit_place_front/domain/community/community_repository/community_detail_repository.dart';

class CommunityDetailState {
  final CommunityDetailDto? communityDetail;
  final bool isLoading;
  final String? errorMessage;

  CommunityDetailState({
    this.communityDetail,
    this.isLoading = false,
    this.errorMessage,
  });

  CommunityDetailState copyWith({
    CommunityDetailDto? communityDetail,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CommunityDetailState(
      communityDetail: communityDetail ?? this.communityDetail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CommunityDetailNotifier extends ChangeNotifier {
  final CommunityDetailRepository _repository = CommunityDetailRepository();
  final int postId;

  CommunityDetailState state = CommunityDetailState();

  CommunityDetailNotifier({required this.postId});

  Future<void> getCommunityDetailInfo() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await _repository.communityDetail(postId: postId);
      final communityDetail = CommunityDetail.fromMap(response);
      final dto = CommunityDetailDto.fromModel(communityDetail);

      state = state.copyWith(communityDetail: dto, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    } finally {
      notifyListeners();
    }
  }

  // getter
  CommunityDetailDto? get communityDetail => state.communityDetail;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
}

final communityDetailProvider =
    ChangeNotifierProvider.family<CommunityDetailNotifier, int>(
  (ref, postId) => CommunityDetailNotifier(postId: postId),
);
