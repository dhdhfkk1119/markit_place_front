import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/detail_page/widgets/community_detail_body.dart';

class CommunityDetailPageDetailPage extends StatelessWidget {
  final int postId;
  const CommunityDetailPageDetailPage({required this.postId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommunityDetailBody(postId: postId),
    );
  }
}
