import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/domain/community/community_dto/community_detail_dto.dart';
import 'package:markit_place_front/domain/community/community_provider/community_detail_notifier.dart';
import 'community_detail_item.dart';
import 'community_detail_item_image.dart';
import 'community_detail_reply.dart';

class CommunityDetailBody extends ConsumerWidget {
  final int postId;
  const CommunityDetailBody({required this.postId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(communityDetailProvider(postId));
    CommunityDetailDto? detail = notifier.state.communityDetail;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CommunityDetailItem(postId: postId),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CommunityDetailItemImage(
              imagePaths: [
                Assets.Images.product,
                Assets.Images.product2,
                "assets/product3.jpg",
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSide(detail?.viewCount ?? 0),
          Divider(thickness: 5, color: Colors.grey.withOpacity(0.3)),
          CommunityDetailReply(0),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSide(int viewCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            CustomWidget.buildTitle("${viewCount} 명이나 봤어요",
                size: 12, color: Colors.grey, weight: FontWeight.w200),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.heart),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
