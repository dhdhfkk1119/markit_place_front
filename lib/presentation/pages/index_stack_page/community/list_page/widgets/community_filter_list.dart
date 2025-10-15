import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/assets.dart';
import '../../../../../../domain/community/community_provider/community_category_notifier.dart';
import '../../../../../../domain/community/community_provider/community_list_notifier.dart';
import '../../../../../../domain/community/community_provider/community_search_status_provider.dart';
import 'community_filter_item.dart';

class CommunityFilterList extends ConsumerStatefulWidget {
  const CommunityFilterList({super.key});

  @override
  ConsumerState<CommunityFilterList> createState() =>
      _CommunityFilterListState();
}

class _CommunityFilterListState extends ConsumerState<CommunityFilterList> {
  // 필터 상태를 관리 (토픽별 true/false)
  final Map<String, bool> _selectedTopics = {};

  @override
  void initState() {
    super.initState();
    // 카테고리 데이터 불러오기
    Future.microtask(() {
      ref.read(communityCategoryProvider).getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(communityCategoryProvider);
    final searchNotifier = ref.watch(communityListProvider.notifier);


    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null) {
      return Center(child: Text("에러: ${notifier.errorMessage}"));
    }

    final categories = notifier.categories;

    return SizedBox.expand(
      child: ListView(
        children: [
          Row(
            children: [
              getTitle('필터'),
              TextButton(
                onPressed: () {
                  // 모든 필터 false로 초기화
                  setState(() {
                    _selectedTopics.updateAll((key, value) => false);
                  });
                  searchNotifier.searchPosts("", []);
                },
                child: Text(
                  "초기화",
                  style: TextStyle(
                    fontFamily: Assets.Fonts.cookieRun,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          Container(height: 2, color: Colors.grey),

          ...categories.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.deepPurpleAccent),
                    const SizedBox(width: 8),
                    getTitle(category.name),
                  ],
                ),
                ...category.topics.map((topic) {
                  final key = topic.name;
                  _selectedTopics.putIfAbsent(key, () => false);
                  return FilterItemWidget(
                    title: key,
                    initialValue: _selectedTopics[key]!,
                    onChanged: (bool newValue) {
                      final currentState = ref.read(communityListProvider);
                      setState(() {
                        _selectedTopics[key] = newValue;
                      });

                      final selectedCategories = _selectedTopics.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();

                      ref.read(selectCommunityCategories.notifier).state = selectedCategories;
                      ref.read(communityListProvider.notifier).searchPosts(
                          currentState.keyword,
                          selectedCategories);

                      print('해당 카테고리 이름 ${selectedCategories}');
                    },
                  );
                }).toList(),
                Container(height: 2, color: Colors.grey),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget getTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        fontFamily: Assets.Fonts.cookieRun,
      ),
    );
  }
}
