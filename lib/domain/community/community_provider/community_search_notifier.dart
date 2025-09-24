import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_model/community_search.dart';
import '../community_repository/community_search_repository.dart';


class CommunitySearchState {
  final List<CommunitySearch> searchResults;
  final bool isLoading;
  final String? error;

  CommunitySearchState({
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  CommunitySearchState copyWith({
    List<CommunitySearch>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return CommunitySearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}


class CommunitySearchNotifier extends StateNotifier<CommunitySearchState> {
  final CommunitySearchRepository _repository;

  CommunitySearchNotifier(this._repository) : super(CommunitySearchState());

  Future<void> search(String keyword) async {
    if (keyword.isEmpty) {
      state = state.copyWith(searchResults: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final dtoList = await _repository.searchPosts(keyword);
      final modelList = dtoList.map((dto) => CommunitySearch.fromDto(dto)).toList();
      state = state.copyWith(searchResults: modelList, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}


final communitySearchProvider = StateNotifierProvider<
    CommunitySearchNotifier,
    CommunitySearchState>((ref) {

  final repository = ref.read(communitySearchRepositoryProvider);
  return CommunitySearchNotifier(repository);
});