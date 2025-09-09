import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/list_page/widgets/community_list_body.dart';

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CommunityListBody(),
    );
  }
}
