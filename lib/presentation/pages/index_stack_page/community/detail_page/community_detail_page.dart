import 'package:flutter/material.dart';
import 'widgets/community_detail_body.dart';

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
