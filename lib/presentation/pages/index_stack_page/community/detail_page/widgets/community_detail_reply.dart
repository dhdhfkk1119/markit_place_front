import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_popup.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

class CommunityDetailReply extends StatelessWidget {
  int replyCount;
  CommunityDetailReply(this.replyCount, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 댓글 달기 전에 위에 정보 (전체 댓글 수 및 정렬)
            CustomWidget.buildTitle("댓글 $replyCount", size: 13),
            _buildReplyInfo(),
          ],
        ),
        // 댓글 단 사람의 프로필 정보
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReplyProfile(),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) =>
                      CustomPopUp.buildAppUpdatePop(context, "수정하기"),
                );
              },
              child: const Icon(Icons.more_vert),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildReplyInfo() {
    return Row(
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () {},
              child: const Text("등록순"),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("조회순"),
            )
          ],
        )
      ],
    );
  }

  Widget _buildReplyProfile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/default_profile.png',
                width: 40,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle("조정우", size: 13),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: CustomWidget.buildTitle("사하구",
                      size: 13, color: Colors.grey, weight: FontWeight.w200),
                ),
                CustomWidget.buildTitle("댓글에 대한 내용이 담기는 곳입니다",
                    size: 13, weight: FontWeight.w200),
                _buildReplyIcon(),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget _buildReplyIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(
                  width: 4,
                ),
                CustomWidget.buildTitle('좋아요',
                    color: Colors.grey, size: 13, weight: FontWeight.w200),
              ],
            ),
          ),
          const SizedBox(
            width: 24,
          ),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                const Icon(
                  Icons.insert_comment_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(
                  width: 4,
                ),
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
