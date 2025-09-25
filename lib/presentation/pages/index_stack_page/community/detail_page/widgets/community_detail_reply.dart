import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_dto/community_comment_like_dot.dart';
import '../../../../../../domain/community/community_model/community_comment.dart';
import '../../../../../../domain/community/community_provider/community_comment_like_notifier.dart';
import '../../../../../../domain/community/community_provider/community_comment_notifier.dart';
import '../../../../../../domain/community/community_provider/community_detail_notifier.dart';

class CommunityDetailReply extends ConsumerWidget {
  final CommunityComment comment;
  final postId;

  const CommunityDetailReply(
      {required this.comment, required this.postId, super.key});

  String _formatDateTime(String dateTimeString, bool isModified) {
    return dateTimeString;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String formattedDate =
        _formatDateTime(comment.displayTime, comment.isModified);
    ref.listen<CommunityCommentState>(communityCommentProvider, (prev, next) {
      if (next.deleteSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("댓글이 삭제되었습니다.")),
        );
        ref.read(communityCommentProvider.notifier).resetAddSuccess();
      } else if (next.updateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("댓글이 수정되었습니다.")),
        );
        ref.read(communityCommentProvider.notifier).resetAddSuccess();
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(communityCommentProvider.notifier).resetAddSuccess();
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReplyProfile(context, formattedDate, ref),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) =>
                    buildReplyPopUp(context, comment, ref, postId),
              );
            },
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyProfile(
      BuildContext context, String formattedDate, WidgetRef ref) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/default_profile.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
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
                  child: CustomWidget.buildTitle(formattedDate,
                      size: 13, color: Colors.grey, weight: FontWeight.w200),
                ),
                CustomWidget.buildTitle(comment.content,
                    size: 13, weight: FontWeight.w200),
                _buildReplyIcon(context, ref),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReplyIcon(BuildContext context, WidgetRef ref) {
    final likeNotifier = ref.watch(communityCommentLikeProvider);
    final likeState = likeNotifier.getLikeState(comment.id) ??
        CommunityCommentLikeDTO(
            liked: false, likeCount: comment.likeCount ?? 0);

    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              await ref
                  .read(communityCommentLikeProvider.notifier)
                  .toggleLike(comment.id);
            },
            child: Row(
              children: [
                Icon(
                  likeState.liked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  color: likeState.liked ? Colors.red : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                CustomWidget.buildTitle('좋아요 ${likeState.likeCount}',
                    color: Colors.grey, size: 13, weight: FontWeight.w200),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  static Widget buildReplyPopUp(
      BuildContext context, CommunityComment comment, WidgetRef ref, postId) {
    final notifier = ref.read(communityCommentProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
          title: const Text("수정하기"),
          onTap: () async {
            Navigator.pop(context);
            final TextEditingController controller =
                TextEditingController(text: comment.content);
            final updated = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("댓글 수정"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "수정할 내용을 입력하세요",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text("취소"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await notifier.updateComment(
                          commentId: comment.id, content: controller.text);
                      await ref
                          .read(communityDetailProvider(postId).notifier)
                          .getCommunityDetailInfo();

                      Navigator.pop(context, true);
                    },
                    child: const Text("수정"),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("삭제하기"),
          onTap: () async {
            Navigator.pop(context);
            final deleted = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("댓글 삭제"),
                content: const Text("정말로 이 댓글을 삭제하시겠습니까?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("취소"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await notifier.deleteComment(comment.id);
                      await ref
                          .read(communityDetailProvider(postId).notifier)
                          .getCommunityDetailInfo();

                      Navigator.pop(context, true);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("삭제"),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.close, color: Colors.grey),
          title: const Text("닫기"),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
