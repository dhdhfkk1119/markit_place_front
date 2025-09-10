import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/list_page/widgets/community_list_app_bar.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/list_page/widgets/community_list_body.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/write_page/community_write_page.dart';

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  bool _isFilterVisible = false;
  String _currentTitle = "부전제2동";
  bool isSearchVisible = false; // 검색창 표시 여부
  final TextEditingController searchController = TextEditingController();

  void toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        onSearchToggle: toggleSearch,
      ),
      body: CommunityListBody(
        isFilterVisible: _isFilterVisible,
        isSearchVisible: isSearchVisible,
        searchController: searchController,
        onWritePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommunityWritePage()),
          );
        },
      ),
    );
  }
}
