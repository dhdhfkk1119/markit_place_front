import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/write_page/widgets/community_write_body.dart';

class CommunityWritePage extends StatelessWidget {
  const CommunityWritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: CommunityWriteBody(),
      ),
    );
  }
}
