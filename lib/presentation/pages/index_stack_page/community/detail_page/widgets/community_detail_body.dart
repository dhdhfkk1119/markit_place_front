import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/constants/custom_popup.dart';
import 'community_detail_item.dart';
import 'community_detail_item_image.dart';
import 'community_detail_reply.dart';

class CommunityDetailBody extends StatelessWidget {
  final int postId;
  const CommunityDetailBody({required this.postId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          _buildLeftAppBarIcon(context),
          const Spacer(),
          _buildRightAppBarIcon(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 상태 구독 및 상세 아이템 호출
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSide(),
            ),
            Divider(thickness: 5, color: Colors.grey.withOpacity(0.3)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CommunityDetailReply(0),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
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
            _buildIcon(const Icon(Icons.send, color: Colors.deepPurpleAccent)),
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

  Widget _buildRightAppBarIcon(BuildContext context) {
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
              builder: (context) =>
                  CustomPopUp.buildAppBarPopUp(context, "조정우", "상품 이름적기", 1),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSide() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            CustomWidget.buildTitle("135명이나 봤어요",
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
