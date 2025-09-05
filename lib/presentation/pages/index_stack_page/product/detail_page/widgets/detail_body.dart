import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

// DetailItem 위젯이 이 페이지에 포함되어 있다고 가정합니다.
// 실제 프로젝트에서는 DetailItem.dart 파일을 import해야 합니다.
class DetailItem extends StatelessWidget {
  @override
  Widget build(BuildContext) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidget.buildTitle(
            "상품 상세 정보",
            size: 20,
          ),
          CustomWidget.buildTitle(
            "50,000원",
            size: 20,
          ),
          CustomWidget.buildTitle(
            "50,000원",
            size: 20,
          ),
          SizedBox(height: 8),
          Text(
            "이 상품은 아주 좋은 상품입니다. 상세한 내용은 아래와 같습니다.",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. 이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
            "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
            "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
            "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다.",
          ),
          SizedBox(height: 200),
          Text("스크롤 끝"),
        ],
      ),
    );
  }
}

class DetailBody extends StatefulWidget {
  const DetailBody({super.key});

  @override
  State<DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        backgroundColor: Colors.transparent, // 앱바 배경을 투명하게 만듭니다.
        elevation: 0, // 앱바 아래 그림자 제거
        actions: [
          // 왼쪽 아이콘 그룹 (AppBar의 leading 속성과 비슷하게 사용)
          _buildLeftAppBarIcon(),
          const Spacer(), // Spacer를 사용하여 양쪽 끝으로 밀어냅니다.
          // 오른쪽 아이콘 그룹
          _buildRightAppBarIcon(),
        ],
      ),
      extendBodyBehindAppBar: true, // body를 앱바 뒤까지 확장합니다.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지가 화면 절반을 차지하는 부분
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InkWell(
                      onTap: () {},
                      child: Image.asset(
                        "assets/product.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // AppBar 아이콘들을 이미지 위에 겹쳐서 표시
                ],
              ),
            ),
            // 이미지가 스크롤되면 함께 올라가는 상품 정보
            DetailItem(),
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
                    borderRadius: BorderRadius.circular(24.0),
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
          _buildIcon(const Icon(CupertinoIcons.back)),
          _buildTitle("커뮤니티", color: Colors.black),
        ],
      ),
    );
  }

  // Right 아이콘
  Widget _buildRightAppBarIcon() {
    return SafeArea(
      child: Row(
        children: [
          _buildIcon(const Icon(CupertinoIcons.profile_circled)),
          _buildIcon(const Icon(CupertinoIcons.heart)),
          _buildIcon(const Icon(Icons.more_vert))
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
