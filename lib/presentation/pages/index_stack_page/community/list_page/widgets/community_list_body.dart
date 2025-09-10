import 'package:flutter/material.dart';
import '../../../../../widgets/WriteButton.dart';
import 'community_filter_list.dart';
import 'community_list_item.dart';

class CommunityListBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isFilterVisible
                      ? const SizedBox(
                          key: ValueKey(true),
                          width: 155,
                          child: CommunityFilterList(),
                        )
                      : const SizedBox.shrink(key: ValueKey(false)),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: 10,
                    itemBuilder: (context, index) =>
                        CommunityListItem(isFilterVisible),
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child:
                          Divider(height: 1, thickness: 1, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSearchVisible)
            Positioned(
              top: 0,
              left: isFilterVisible ? 170 : 0, // 필터 있을 때 위치 조정
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "검색어를 입력하세요",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    print("검색: $value");
                  },
                ),
              ),
            ),
          WriteButton(
            onTap: onWritePressed,
            title: "글쓰기",
          ),
        ],
      ),
    );
  }
}
