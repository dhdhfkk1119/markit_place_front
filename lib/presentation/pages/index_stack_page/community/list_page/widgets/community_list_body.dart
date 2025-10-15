import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/community/community_provider/community_list_notifier.dart';
import '../../../../../../domain/community/community_provider/community_search_status_provider.dart';
import '../../../../../widgets/WriteButton.dart';
import 'community_filter_list.dart';
import 'community_list_item.dart';

class CommunityListBody extends ConsumerStatefulWidget {
  final bool isFilterVisible;
  final VoidCallback onWritePressed;
  final TextEditingController searchController;
  final bool isSearchVisible;

  const CommunityListBody({
    super.key,
    required this.isFilterVisible,
    required this.onWritePressed,
    required this.isSearchVisible,
    required this.searchController,
  });

  @override
  ConsumerState<CommunityListBody> createState() => _CommunityListBodyState();
}

class _CommunityListBodyState extends ConsumerState<CommunityListBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityListProvider.notifier).getCommunityList();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(communityListProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // CommunityListBody.dart

  Future<void> _onRefresh() async {
    final notifier = ref.read(communityListProvider.notifier);
    final currentCategories = ref.read(selectCommunityCategories).whereType<String>().toList();
    if (notifier.state.keyword.isNotEmpty || currentCategories.isNotEmpty) {
      await notifier.searchPosts(notifier.state.keyword, currentCategories);
    } else {
      await notifier.getCommunityList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityListProvider);
    final categories = ref.watch(selectCommunityCategories);
    print('list BODY 에서 가져온 카테고리 : ${categories}');
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.isFilterVisible
                      ? const SizedBox(
                    key: ValueKey(true),
                    width: 155,
                    child: CommunityFilterList(),
                  )
                      : const SizedBox.shrink(key: ValueKey(false)),
                ),
                Expanded(
                  child: state.errorMessage != null
                      ? Center(child: Text('에러: ${state.errorMessage}'))
                      : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: state.communityList.length + (state.isLoading && state.communityList.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < state.communityList.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CommunityListItem(
                              state.communityList[index],
                              widget.isFilterVisible,
                            ),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                      separatorBuilder: (_, __) => const Divider(
                        height: 32,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isSearchVisible)
            Positioned(
              top: 0,
              left: widget.isFilterVisible ? 170 : 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: "검색어를 입력하세요",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    ref.read(communityListProvider.notifier)
                        .searchPosts(value,categories.whereType<String>().toList());
                  },
                ),
              ),
            ),
          WriteButton(
            onTap: widget.onWritePressed,
            title: "글쓰기",
          ),
        ],
      ),
    );
  }
}