import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

class MyProfileBody extends StatefulWidget {
  const MyProfileBody({super.key});

  @override
  State<MyProfileBody> createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<MyProfileBody> {
  static const Color primaryColor = Color(0xFF5E2B96);
  static const Color profileAvatarColor = Color(0xFFFF9016);
  static const Color accentColor = Color(0xFFE7D9F8);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color redHeartColor = Colors.red;
  static const double horizontalPadding = 20.0;
  static const double verticalSpacing = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle("프로필", size: 18),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // 더보기 메뉴 기능
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 프로필 섹션
              _buildProfileSection(),
              const SizedBox(height: verticalSpacing),

              // 재거래 및 응답률 섹션
              _buildRateSection(),
              const SizedBox(height: verticalSpacing),

              // 판매 물품 섹션
              _buildListTile(
                title: "판매 물품",
                subTitle: "판매 중인 물품이 없습니다",
                onTap: () {},
              ),
              const SizedBox(height: verticalSpacing),

              // 받은 매너 평가 섹션
              _buildListTile(
                title: "받은 매너 평가",
                onTap: () {},
              ),
              const SizedBox(height: 10),

              _buildMannerSection(),
              const SizedBox(height: verticalSpacing),

              // 받은 거래 후기 섹션
              _buildListTile(
                title: "받은 거래 후기",
                subTitle: "32",
                onTap: () {},
              ),
              const SizedBox(height: 10),

              // 거래 후기 댓글
              _buildReviewSection(),
              const SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  // 거래 후기 섹션 위젯
  Widget _buildReviewSection() {
    return Column(
      children: [
        _buildReviewComment(
          "꼼꼼하게 확인해주시고, 친절하게 답해주셔서 좋은 거래할 수 있었습니다! 감사합니다.",
          "강아지는야옹",
        ),
        _buildReviewComment(
          "매우 친절하고 쿨거래해주셨어요. 덕분에 좋은 거래 했습니다.",
          "진순이킬러",
        ),
        _buildReviewComment(
          "시간약속 잘지켜주시고 친절하세요. 믿고 거래할 수 있는 분입니다. 추천드려요!",
          "대머리도사",
        ),
      ],
    );
  }

  // 거래 후기 댓글 위젯
  Widget _buildReviewComment(String text, String author) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidget.buildTitle(text, size: 14, color: Colors.black, weight: FontWeight.normal),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomWidget.buildTitle("- $author", size: 12, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
  
  // 프로필 섹션 위젯
  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: profileAvatarColor,
              child: Text("🍔", style: TextStyle(fontSize: 40)),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.refresh, color: Colors.grey, size: 16),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.buildTitle("바보임당", size: 20, weight: FontWeight.w700),
              CustomWidget.buildTitle("#zsswie5", size: 14, color: Colors.grey),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: lightGrey),
                        backgroundColor: lightGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: CustomWidget.buildTitle("매너 칭찬하기", size: 12, color: Colors.black, weight: FontWeight.normal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accentColor),
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: CustomWidget.buildTitle("모아보기", size: 12, color: primaryColor, weight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 재거래 및 응답률 섹션 위젯
  Widget _buildRateSection() {
    return Row(
      children: [
        Expanded(
          child: _buildRateBox(
            icon: Icons.favorite,
            rate: "89%",
            text: "재거래 희망률",
            subText: "9명 중 8명 만족",
            iconColor: redHeartColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRateBox(
            icon: Icons.wechat,
            rate: "80%",
            text: "응답률",
            subText: "보통 30분 이내 응답",
            iconColor: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  // 매너 평가 섹션 위젯
  Widget _buildMannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMannerRow(icon: Icons.favorite, count: 8, text: "친절하고 매너가 좋아요.", iconColor: redHeartColor),
        _buildMannerRow(icon: Icons.access_time_filled, count: 5, text: "시간 약속을 잘 지켜요."),
        _buildMannerRow(icon: Icons.wechat_rounded, count: 5, text: "응답이 빨라요.", iconColor: Colors.black),
      ],
    );
  }

  // 재거래/응답률 박스 위젯
  Widget _buildRateBox({
    required IconData icon,
    required String rate,
    required String text,
    required String subText,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 5),
              CustomWidget.buildTitle(text, size: 14, color: primaryColor, weight: FontWeight.normal),
            ],
          ),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(rate, size: 22, color: primaryColor, weight: FontWeight.w700),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(subText, size: 12, color: Colors.grey.shade600, weight: FontWeight.normal),
        ],
      ),
    );
  }

  // 리스트 타일 위젯 (판매 물품, 매너 평가, 후기 등)
  Widget _buildListTile({
    required String title,
    String? subTitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: lightGrey)),
        ),
        child: Row(
          children: [
            CustomWidget.buildTitle(title, size: 16, weight: FontWeight.w700),
            const SizedBox(width: 8),
            if (subTitle != null)
              CustomWidget.buildTitle(subTitle, size: 16, color: Colors.grey, weight: FontWeight.normal),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 매너 평가 태그 위젯
  Widget _buildMannerRow({
    required IconData icon,
    required int count,
    required String text,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          CustomWidget.buildTitle(count.toString(), size: 16, weight: FontWeight.w700),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomWidget.buildTitle(text, size: 12, color: Colors.black, weight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}