import 'package:flutter/material.dart';
import '../../../../../../_core/constants/custom_popup.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_model/community_comment.dart';

class CommunityDetailReply extends StatelessWidget {
  final CommunityComment comment;
  const CommunityDetailReply({required this.comment, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReplyProfile(),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) =>
                    CustomPopUp.buildAppUpdatePop(context, "수정하기"),
              );
            },
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyProfile() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            // comment.imageUrl을 사용하여 프로필 이미지 표시, 없으면 기본 이미지
            child: (comment.imageUrl != null && comment.imageUrl!.isNotEmpty)
                ? Image.network(
                    comment.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/default_profile.png',
                        width: 40), // 에러 이미지
                  )
                : Image.asset('assets/default_profile.png', width: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(comment.writerName, size: 13),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: CustomWidget.buildTitle(comment.createdAt,
                      size: 13, color: Colors.grey, weight: FontWeight.w200),
                ),
                CustomWidget.buildTitle(comment.content,
                    size: 13, weight: FontWeight.w200),
                _buildReplyIcon(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReplyIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              // 댓글 좋아요 기능
            },
            child: Row(
              children: [
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                CustomWidget.buildTitle('좋아요 ${comment.likeCount ?? 0}',
                    color: Colors.grey, size: 13, weight: FontWeight.w200),
              ],
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          InkWell(
            onTap: () {
              // 대댓글 작성 기능
            },
            child: Row(
              children: [
                const Icon(
                  Icons.insert_comment_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                CustomWidget.buildTitle('댓글',
                    color: Colors.grey, size: 13, weight: FontWeight.w200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
