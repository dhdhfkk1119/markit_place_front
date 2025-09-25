import '../community_model/community_list.dart';

class CommunityListState {
  final List<CommunityList> communityList;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final bool isLastPage;
  final String keyword;

  CommunityListState({
    this.communityList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 0,
    this.isLastPage = false,
    this.keyword = "",
  });

  CommunityListState copyWith({
    List<CommunityList>? communityList,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    bool? isLastPage,
    String? keyword,
  }) {
    return CommunityListState(
      communityList: communityList ?? this.communityList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
      keyword: keyword ?? this.keyword,
    );
  }
}