import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/custom_popup.dart';
import '../../../../../domain/community/community_dto/community_detail_dto.dart';
import '../../../../../domain/community/community_provider/community_detail_notifier.dart';
import 'widgets/community_detail_body.dart';

class CommunityDetailPageDetailPage extends ConsumerWidget {
  final int postId;
  const CommunityDetailPageDetailPage({required this.postId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final notifier = ref.watch(communityDetailProvider(postId));

    if (notifier.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    if (notifier.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text("오류가 발생했습니다: ${notifier.errorMessage}"),
        ),
      );
    }


    final dto = notifier.communityDetail;
    if (dto == null) {
      return const Scaffold(
        body: Center(child: Text("게시물을 찾을 수 없습니다.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          _buildLeftAppBarIcon(context),
          const Spacer(),
          _buildRightAppBarIcon(context, ref, dto),
        ],
      ),
      body: CommunityDetailBody(postId: postId),
      bottomSheet: _buildChatInput(),
    );
  }

  Widget _buildChatInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(const Icon(CupertinoIcons.heart)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "메시지를 입력하세요...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildIcon(
              const Icon(Icons.send, color: Colors.deepPurpleAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftAppBarIcon(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          _buildIcon(const Icon(CupertinoIcons.back), onPressed: () {
            Navigator.pop(context);
          }),
          _buildTitle("커뮤니티"),
        ],
      ),
    );
  }

  Widget _buildRightAppBarIcon(BuildContext context, WidgetRef ref, CommunityDetailDto dto) {
    return SafeArea(
      child: Row(
        children: [
          _buildIcon(
              const Icon(CupertinoIcons.profile_circled, color: Colors.black)),
          _buildIcon(const Icon(CupertinoIcons.heart, color: Colors.black)),
          _buildIcon(const Icon(Icons.more_vert), onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                // 커뮤니티 게시글용 팝업을 별도로 만들어 사용
                return CustomPopUp.buildCommunityAppBarPopUp(context, dto, ref);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, {Color? color, FontWeight? weight}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontFamily: Assets.Fonts.cookieRun,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? Colors.black,
      ),
    );
  }

  Widget _buildIcon(Icon icon,
      {double? size, Color? color, VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed ?? () {},
      icon:
          Icon(icon.icon, size: size ?? icon.size, color: color ?? icon.color),
    );
  }
}
