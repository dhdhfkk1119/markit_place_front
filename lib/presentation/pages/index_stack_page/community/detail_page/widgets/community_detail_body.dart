import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../_core/constants/custom_popup.dart';
import 'community_detail_item.dart';
import 'community_detail_item_image.dart';

class CommunityDetailBody extends StatefulWidget {
  const CommunityDetailBody({super.key});

  @override
  State<CommunityDetailBody> createState() => _CommunityDetailBodyState();
}

class _CommunityDetailBodyState extends State<CommunityDetailBody> {
  final ScrollController _scrollController = ScrollController(); //스크롤 위치 설정
  Color _appBarColor = Colors.transparent; // 동적으로 색상 변경(스클로에 따라)
  Color _iconColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset.clamp(0, 100);
    double t = offset / 100;

    setState(() {
      _appBarColor = Color.lerp(Colors.transparent, Colors.white, t)!;
      _iconColor = Color.lerp(Colors.white, Colors.black, t)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // body가 앱바 뒤로 확장되게 설정
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        backgroundColor: _appBarColor, // 앱바 배경을 투명하게 만듭니다.
        elevation: 0, // 앱바 아래 그림자 제거
        actions: [
          // 왼쪽 아이콘 그룹 (AppBar의 leading 속성과 비슷하게 사용)
          _buildLeftAppBarIcon(),
          const Spacer(), // Spacer를 사용하여 양쪽 끝으로 밀어냅니다.
          // 오른쪽 아이콘 그룹
          _buildRightAppBarIcon(),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            CommunityDetailItemImage(
              imagePaths: [
                "assets/product.jpg",
                "assets/product2.jpg",
                "assets/product3.jpg",
              ],
            ),
            // 이미지가 스크롤되면 함께 올라가는 상품 정보
            CommunityDetailItem(),
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
              Icon(
                CupertinoIcons.back,
                color: _iconColor,
              ), onPressed: () {
            Navigator.pop(context);
          }),
          _buildTitle(
            "커뮤니티",
            color: _iconColor,
          ),
        ],
      ),
    );
  }

  // Right 아이콘
  Widget _buildRightAppBarIcon() {
    return SafeArea(
      child: Row(
        children: [
          _buildIcon(Icon(
            CupertinoIcons.profile_circled,
            color: Colors.black,
          )),
          _buildIcon(Icon(CupertinoIcons.heart, color: Colors.black)),
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

  // 텍스트 처리
  Widget _buildTitle(String title, {Color? color, FontWeight? weight}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontFamily: "CookieRun",
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
