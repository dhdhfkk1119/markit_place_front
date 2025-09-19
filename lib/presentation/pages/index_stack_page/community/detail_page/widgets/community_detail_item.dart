import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_dto/community_detail_dto.dart';
import '../../../../../../domain/community/community_provider/community_detail_notifier.dart';

class CommunityDetailItem extends ConsumerStatefulWidget {
  final int postId;
  const CommunityDetailItem({required this.postId, super.key});

  @override
  ConsumerState<CommunityDetailItem> createState() =>
      _CommunityDetailItemState();
}

class _CommunityDetailItemState extends ConsumerState<CommunityDetailItem> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(communityDetailProvider(widget.postId)).getCommunityDetailInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(communityDetailProvider(widget.postId));

    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null) {
      return Center(child: Text('오류 발생: ${notifier.errorMessage}'));
    }

    final post = notifier.communityDetail!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfile(post),
        const SizedBox(height: 16),
        CustomWidget.buildTitle("${post.title}", size: 20),
        const SizedBox(height: 8),
        Text("${post.content}", style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildProfile(CommunityDetailDto dto) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            Assets.Images.defaultProfile,
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.buildTitle(dto.writerName, size: 16),
            CustomWidget.buildTitle(dto.location,
                size: 12, color: Colors.grey, weight: FontWeight.w200),
          ],
        ),
      ],
    );
  }
}
