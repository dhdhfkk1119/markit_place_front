import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/community/community_provider/community_list_notifier.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityListProvider.notifier).getCommunityList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(communityListProvider);

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
                  child: notifier.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifier.errorMessage != null
                          ? Center(child: Text('에러: ${notifier.errorMessage}'))
                          : ListView.separated(
                              itemCount: notifier.communityList.length,
                              itemBuilder: (context, index) =>
                                  CommunityListItem(
                                notifier.communityList[index],
                                widget.isFilterVisible,
                              ),
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
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
                    ref
                        .read(communityListProvider.notifier)
                        .getCommunityList(); // 검색 실행
                    print("검색: $value");
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
