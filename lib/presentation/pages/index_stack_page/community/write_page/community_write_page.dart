import 'package:flutter/material.dart';
import 'widgets/community_write_body.dart';

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
