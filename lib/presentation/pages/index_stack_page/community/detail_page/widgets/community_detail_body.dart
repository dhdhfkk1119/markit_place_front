import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_model/community_comment.dart';
import '../../../../../../domain/community/community_dto/community_detail_dto.dart';
import '../../../../../../domain/community/community_provider/community_detail_notifier.dart';
import 'community_detail_item.dart';
import 'community_detail_item_image.dart';
import 'community_detail_reply.dart';

class CommunityDetailBody extends ConsumerWidget {
  final int postId;
  const CommunityDetailBody({required this.postId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityNotifier = ref.watch(communityDetailProvider(postId));
    final CommunityDetailDto? detail = communityNotifier.communityDetail;
    final List<CommunityComment> comments = detail?.comments ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CommunityDetailItem(postId: postId),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CommunityDetailItemImage(
              imagePaths: detail?.images ?? [],
            ),
          ),
          const SizedBox(height: 16),
          _buildSide(detail, ref),
          Divider(thickness: 5, color: Colors.grey.withOpacity(0.3)),
          if (detail != null)
            _buildCommentHeader(comments.length, ref, context),
          if (comments.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommunityDetailReply(comment: comments[index]);
              },
            )
          else if (detail != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: CustomWidget.buildTitle(
                  "등록된 댓글이 없습니다.",
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSide(CommunityDetailDto? detail, WidgetRef ref) {
    final viewCount = detail?.viewCount ?? 0;
    final isLikedByMe = detail?.isLiked ?? false;
    final likeCount = detail?.likeCount ?? 0;

    final notifier = ref.read(communityDetailProvider(postId).notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            CustomWidget.buildTitle(
              "$viewCount 명이나 봤어요",
              size: 12,
              color: Colors.grey,
              weight: FontWeight.w200,
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () => notifier.toggleLike(),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      isLikedByMe
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: isLikedByMe ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$likeCount",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentHeader(
      int commentCount, WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomWidget.buildTitle("댓글 $commentCount", size: 13),
          _buildReplySortOptions(ref, context),
        ],
      ),
    );
  }

  Widget _buildReplySortOptions(WidgetRef ref, BuildContext context) {
    final notifier = ref.read(communityDetailProvider(postId).notifier);
    final currentSortOrder = ref.watch(
      communityDetailProvider(postId).select((state) => state.currentSortOrder),
    );

    final activeColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    const inactiveColor = Colors.grey;

    return Row(
      children: [
        TextButton(
          onPressed: () => notifier.sortComments(CommentSortOrder.registration),
          child: Text(
            "등록순",
            style: TextStyle(
              color: currentSortOrder == CommentSortOrder.registration
                  ? activeColor
                  : inactiveColor,
              fontWeight: currentSortOrder == CommentSortOrder.registration
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => notifier.sortComments(CommentSortOrder.latest),
          child: Text(
            "최신순",
            style: TextStyle(
              color: currentSortOrder == CommentSortOrder.latest
                  ? activeColor
                  : inactiveColor,
              fontWeight: currentSortOrder == CommentSortOrder.latest
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        )
      ],
    );
  }
}
