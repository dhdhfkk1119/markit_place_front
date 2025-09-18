import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/domain/community/community_dto/community_detail_dto.dart';
import 'package:markit_place_front/domain/community/community_provider/community_detail_notifier.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_popup.dart';
import 'community_detail_item.dart';
import 'community_detail_item_image.dart';
import 'community_detail_reply.dart';

class CommunityDetailBody extends StatefulWidget {
  final int postId;
  const CommunityDetailBody({required this.postId, super.key});

  @override
  State<CommunityDetailBody> createState() => _CommunityDetailBodyState();
}

class _CommunityDetailBodyState extends State<CommunityDetailBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        actions: [
          _buildLeftAppBarIcon(),
          const Spacer(), // Spacer를 사용하여 양쪽 끝으로 밀어냅니다.
          _buildRightAppBarIcon(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CommunityDetailItem(postId: widget.postId),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                children: [_buildSide()],
              ),
            ),
            Divider(
              thickness: 5,
              color: Colors.grey.withOpacity(0.3),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: CommunityDetailReply(0),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
      bottomSheet: _buildChatInput(),
    );
  }

  // 메세지 보내는 필드
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
              offset: const Offset(0, -3), // 위쪽에 그림자
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
            _buildIcon(const Icon(Icons.send, color: Colors.deepPurpleAccent)),
          ],
        ),
      ),
    );
  }

  // Left 아이콘
  Widget _buildLeftAppBarIcon() {
    return SafeArea(
      child: Row(
        children: [
          _buildIcon(
              const Icon(
                CupertinoIcons.back,
              ), onPressed: () {
            Navigator.pop(context);
          }),
          _buildTitle(
            "커뮤니티",
          ),
        ],
      ),
    );
  }

  // Right 아이콘 + (신고)
  Widget _buildRightAppBarIcon() {
    return SafeArea(
      child: Row(
        children: [
          _buildIcon(const Icon(
            CupertinoIcons.profile_circled,
            color: Colors.black,
          )),
          _buildIcon(const Icon(CupertinoIcons.heart, color: Colors.black)),
          _buildIcon(
            const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) =>
                    CustomPopUp.buildAppBarPopUp(context, "조정우", "상품 이름적기", 1),
              );
            },
          )
        ],
      ),
    );
  }

  // 조회수 및 좋아요 누르기
  Widget _buildSide() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 조회수
        Row(
          children: [
            const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 4),
            CustomWidget.buildTitle(
              "135명이나 봤어요",
              size: 12,
              color: Colors.grey,
              weight: FontWeight.w200,
            ),
          ],
        ),
        // 좋아요
        Row(
          children: [
            InkWell(
              onTap: () {
                // 좋아요 누르기 처리
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                // 아이콘 주변에 원하는 만큼 패딩을 줄 수 있습니다.
                padding: EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.heart),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 텍스트 처리
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

  // 아이콘 처리
  Widget _buildIcon(
    Icon icon, {
    double? size,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed ?? () {},
      icon: Icon(
        icon.icon,
        size: size ?? icon.size,
        color: color ?? icon.color,
      ),
    );
  }
}
