import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import '../../../../../../domain/providers/auth_form/SessionNotifier.dart';
import '../../my_profile_page/widgets/my_profile_body.dart';

class MyPageBody extends ConsumerStatefulWidget {
  const MyPageBody({super.key});

  @override
  ConsumerState<MyPageBody> createState() => _MyPageBodyState();
}

class _MyPageBodyState extends ConsumerState<MyPageBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Container(
        color: const Color(0xFFF0EBF9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile Section with "Profile View" Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child:
                              Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomWidget.buildTitle(
                                "아자몽다",
                                size: 18,
                                weight: FontWeight.w200,
                              ),
                              const SizedBox(height: 5),
                              CustomWidget.buildTitle(
                                "전포동 #22",
                                size: 14,
                                color: Colors.grey,
                                weight: FontWeight.w200,
                              )
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.grey, size: 20)
                      ],
                    ),
                    const SizedBox(height: 16),
                    // "프로필 보기
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProfileBody(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomWidget.buildTitle(
                            "프로필 보기",
                            size: 14,
                            weight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // "O-pay" banner
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.paid_outlined,
                          size: 32, color: Color(0xFF5E2B96)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget.buildTitle(
                            "MP PAY",
                            size: 14,
                            weight: FontWeight.w200,
                          ),
                          CustomWidget.buildTitle(
                            "중고거래는 이제 MP페이를 이용해보세요!",
                            size: 14,
                            weight: FontWeight.w200,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 30),

              // Icon menu section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIconButton(
                      icon: Icons.shopping_bag_outlined,
                      text: "판매 내역",
                      color: const Color(0xFFE7D9F8),
                      iconColor: Colors.white,
                    ),
                    _buildIconButton(
                      icon: Icons.shopping_cart_outlined,
                      text: "구매 내역",
                      color: const Color(0xFFE7D9F8),
                      iconColor: Colors.white,
                    ),
                    _buildIconButton(
                      icon: Icons.favorite_border,
                      text: "관심 목록",
                      color: const Color(0xFFE7D9F8),
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ),

              const Divider(height: 30),

              // Local settings and other menu section
              _buildMenuTile(
                icon: Icons.my_location_outlined,
                text: "내 동네 설정",
              ),
              _buildMenuTile(
                icon: Icons.check_circle_outline,
                text: "동네 인증",
              ),
              _buildMenuTile(
                icon: Icons.search_outlined,
                text: "키워드 등록",
              ),
              const Divider(height: 30),
              _buildMenuTile(
                icon: Icons.headphones_outlined,
                text: "고객 센터",
                showArrow: true,
              ),
              _buildMenuTile(
                icon: Icons.announcement_outlined,
                text: "공지 사항",
                showArrow: true,
              ),
              InkWell(
                onTap: () async {
                  await ref.read(sessionProvider.notifier).logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, "/social-login");
                  }
                },
                child: _buildMenuTile(
                  icon: Icons.logout,
                  text: "로그아웃",
                  showArrow: true,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String text,
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(icon, color: iconColor, size: 30),
        ),
        const SizedBox(height: 8),
        CustomWidget.buildTitle(text, size: 12, weight: FontWeight.w200),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String text,
    bool showArrow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 15),
          CustomWidget.buildTitle(text, size: 16, weight: FontWeight.w200),
          const Spacer(),
          if (showArrow)
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
