import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/community/community_provider/community_list_notifier.dart';
import '../write_page/community_write_page.dart';
import 'widgets/community_list_app_bar.dart';
import 'widgets/community_list_body.dart';

final searchVisibleProvider = StateProvider<bool>((ref) => false);
final searchControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class CommunityListPage extends ConsumerStatefulWidget {
  const CommunityListPage({super.key});

  @override
  ConsumerState<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends ConsumerState<CommunityListPage> {
  bool _isFilterVisible = false;
  String _currentTitle = "부전제2동";

  @override
  Widget build(BuildContext context) {
    final isSearchVisible = ref.watch(searchVisibleProvider);
    final searchController = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: CommunityListAppBar(
        currentTitle: _currentTitle,
        onTitleChanged: (newTitle) {
          setState(() {
            _currentTitle = newTitle;
          });
        },
        onFilterToggle: () {
          setState(() {
            _isFilterVisible = !_isFilterVisible;
          });
        },
        onSearchToggle: () {
          ref.read(searchVisibleProvider.notifier).state = !isSearchVisible;
          if (!isSearchVisible) {
            searchController.clear();
          }
        },
      ),
      body: CommunityListBody(
        isFilterVisible: _isFilterVisible,
        isSearchVisible: isSearchVisible,
        searchController: searchController,
        onWritePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommunityWritePage()),
          ).then((_) {
            ref.read(communityListProvider.notifier).getCommunityList();
          });
        },
      ),
    );
  }
}
