import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/custom_popup.dart';
import '../../../../../domain/community/community_dto/community_detail_dto.dart';
import '../../../../../domain/community/community_provider/community_detail_notifier.dart';
import '../../../../../domain/community/community_provider/community_comment_notifier.dart';
import 'widgets/community_detail_body.dart';


class CommunityDetailPage extends ConsumerStatefulWidget {
  final int postId;
  const CommunityDetailPage({required this.postId, super.key});

  @override
  ConsumerState<CommunityDetailPage> createState() =>
      _CommunityDetailPageDetailPageState();
}

class _CommunityDetailPageDetailPageState
    extends ConsumerState<CommunityDetailPage> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    Future.microtask(() {
      ref.read(communityDetailProvider(widget.postId).notifier).getCommunityDetailInfo();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }


  void _refreshDetailPage() {
    ref.read(communityDetailProvider(widget.postId).notifier).getCommunityDetailInfo();
  }

  @override
  Widget build(BuildContext context) {
    final communityDetailWatch =
    ref.watch(communityDetailProvider(widget.postId));
    final CommunityDetailDto? dto = communityDetailWatch.communityDetail;
    final bool isLoadingDetail = communityDetailWatch.isLoading;
    final String? detailErrorMessage = communityDetailWatch.errorMessage;

    ref.listen<CommunityCommentState>(communityCommentProvider,
            (previous, next) {
          if (next.addSuccess) {
            _commentController.clear();
            _refreshDetailPage();
            ref.read(communityCommentProvider.notifier).resetAddSuccess();
          }
        });

    if (isLoadingDetail && dto == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (dto == null && detailErrorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: _buildTitle(context, "오류")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  "데이터를 불러오는데 실패했습니다.\n$detailErrorMessage",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _refreshDetailPage,
                  child: const Text("다시 시도"),
                )
              ],
            ),
          ),
        ),
      );
    } else if (dto == null) {
      return Scaffold(
        appBar: AppBar(title: _buildTitle(context, "정보 없음")),
        body: const Center(child: Text("게시글 정보를 찾을 수 없습니다.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
        _buildIcon(context, const Icon(CupertinoIcons.back), onPressed: () {
          Navigator.pop(context);
        }),
        title: _buildTitle(context, "커뮤니티"),
        actions: [
          _buildRightAppBarIcon(context, ref, dto),
        ],
      ),
      body: CommunityDetailBody(postId: widget.postId),
      bottomSheet:
      _buildChatInput(context, ref, widget.postId, _commentController),
    );
  }

  Widget _buildChatInput(BuildContext context, WidgetRef ref, int currentPostId,
      TextEditingController controller) {
    final commentState = ref.watch(communityCommentProvider);
    final isAddingComment = commentState.isAdding;
    final addCommentError = commentState.errorMessage;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (addCommentError != null && !isAddingComment)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    addCommentError,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isAddingComment,
                      decoration: InputDecoration(
                        hintText: "댓글을 입력하세요...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                            Colors.grey[200],
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onSubmitted: (value) {
                        if (value.isNotEmpty && !isAddingComment) {
                          ref
                              .read(communityCommentProvider.notifier)
                              .addComment(
                            postId: currentPostId,
                            content: value,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  isAddingComment
                      ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.0))
                      : IconButton(
                    icon: Icon(Icons.send,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      final commentText = controller.text;
                      if (commentText.isNotEmpty) {
                        FocusScope.of(context).unfocus();
                        ref
                            .read(communityCommentProvider.notifier)
                            .addComment(
                          postId: currentPostId,
                          content: commentText,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightAppBarIcon(
      BuildContext context, WidgetRef ref, CommunityDetailDto dto) {
    return Row(
      children: [
        _buildIcon(context, const Icon(CupertinoIcons.profile_circled),
            color: Theme.of(context).iconTheme.color),
        _buildIcon(context, const Icon(CupertinoIcons.heart),
            color: Theme.of(context).iconTheme.color),
        _buildIcon(context, const Icon(Icons.more_vert), onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (bContext) {
              return CustomPopUp.buildCommunityAppBarPopUp(bContext, dto, ref);
            },
          ).then((_) {
            _refreshDetailPage();
          });
        }),
      ],
    );
  }

  //
  Widget _buildTitle(BuildContext context, String title,
      {Color? color, FontWeight? weight}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontFamily: Assets.Fonts.cookieRun,
        fontWeight: weight ?? FontWeight.w700,
        color: color ??
            Theme.of(context).appBarTheme.titleTextStyle?.color ??
            Colors.black,
      ),
    );
  }

  Widget _buildIcon(BuildContext context, Icon icon,
      {double? size, Color? color, VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed ?? () {},
      icon: Icon(icon.icon,
          size: size ?? icon.size ?? Theme.of(context).iconTheme.size,
          color: color ?? icon.color ?? Theme.of(context).iconTheme.color),
    );
  }
}