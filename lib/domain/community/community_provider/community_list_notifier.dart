import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../community_dto/community_list_dto.dart';
import '../community_model/community_list.dart';
import '../community_repository/community_list_repository.dart';
import '../community_state/community_list_state.dart';

class CommunityListNotifier extends StateNotifier<CommunityListState> {
  final CommunityListRepository _repository;

  CommunityListNotifier(this._repository) : super(CommunityListState());

  Future<void> getCommunityList({bool isRefresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null, keyword: "");

    try {
      final List<CommunityListDTO>? dtoList =
          await _repository.fetchCommunityList(page: 0);

      if (dtoList == null) {
        state = state.copyWith(
          communityList: [],
          isLoading: false,
          currentPage: 0,
          isLastPage: true,
        );
        return;
      }

      final modelList =
          dtoList.map((dto) => CommunityList.fromModel(dto)).toList();
      state = state.copyWith(
        communityList: modelList,
        isLoading: false,
        currentPage: 0,
        isLastPage: modelList.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      if (kDebugMode) {
        print("CommunityListNotifier: Error fetching list - $e");
      }
    }
  }

  Future<void> searchPosts(String keyword,List<String> categories) async {
    if (state.isLoading) return;

    if (keyword.isEmpty) {
      await getCommunityList();
      return;
    }

    state =
        state.copyWith(isLoading: true, errorMessage: null, keyword: keyword);

    try {
      final List<CommunityListDTO>? dtoList = await _repository.searchPosts(
        keyword: keyword,
        categories: categories,
        sortType: "latest",
        page: 0,
        size: 10,
      );

      if (dtoList == null) {
        state = state.copyWith(
          communityList: [],
          isLoading: false,
          currentPage: 0,
          isLastPage: true,
        );
        return;
      }

      final modelList =
          dtoList.map((dto) => CommunityList.fromModel(dto)).toList();

      state = state.copyWith(
        communityList: modelList,
        isLoading: false,
        currentPage: 0,
        isLastPage: modelList.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      if (kDebugMode) {
        print("CommunityListNotifier: Error searching posts - $e");
      }
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final List<CommunityListDTO>? dtoList = state.keyword.isNotEmpty
          ? await _repository.searchPosts(
              keyword: state.keyword,
              categories: [],
              sortType: "latest",
              page: nextPage,
              size: 10,
            )
          : await _repository.fetchCommunityList(page: nextPage);

      if (dtoList == null) {
        state = state.copyWith(isLoading: false, isLastPage: true);
        return;
      }

      final modelList =
          dtoList.map((dto) => CommunityList.fromModel(dto)).toList();

      state = state.copyWith(
        communityList: [...state.communityList, ...modelList],
        isLoading: false,
        currentPage: nextPage,
        isLastPage: modelList.isEmpty || modelList.length < 10,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      if (kDebugMode) {
        print("CommunityListNotifier: Error loading next page - $e");
      }
    }
  }

  void updatePostLikeStatus(int postId, bool newIsLiked, int newLikeCount) {
    final index = state.communityList.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final updatedList = List<CommunityList>.from(state.communityList);
      updatedList[index] = updatedList[index].copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      );
      state = state.copyWith(communityList: updatedList);
    }
  }

  void updatePostViewCount(int postId, int newViewCount) {
    final index = state.communityList.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final updatedList = List<CommunityList>.from(state.communityList);
      updatedList[index] = updatedList[index].copyWith(
        viewCount: newViewCount,
      );
      state = state.copyWith(communityList: updatedList);
    }
  }

  void updatePostInList(CommunityListDTO updatedPostDTO) {
    final updatedPostModel = CommunityList.fromModel(updatedPostDTO);
    final index = state.communityList
        .indexWhere((post) => post.id == updatedPostModel.id);
    if (index != -1) {
      final updatedList = List<CommunityList>.from(state.communityList);
      updatedList[index] = updatedPostModel;
      state = state.copyWith(communityList: updatedList);
    }
  }

  void removePostFromList(int postId) {
    state = state.copyWith(
      communityList:
          state.communityList.where((post) => post.id != postId).toList(),
    );
  }
}

final communityListProvider =
    StateNotifierProvider<CommunityListNotifier, CommunityListState>((ref) {
  final repository = ref.read(communityListRepositoryProvider);
  return CommunityListNotifier(repository);
});
