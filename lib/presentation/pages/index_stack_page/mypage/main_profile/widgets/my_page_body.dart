import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../auth/social_login_page/social_login_page.dart';
import '../../my_profile_page/widgets/my_profile_body.dart';
import '../qna_screen.dart';
import '../notice_screen.dart';
import '../sales_list_screen.dart';
import '../purchase_list_screen.dart';
import '../favorite_list_screen.dart';

class MyPageBody extends ConsumerStatefulWidget {
  const MyPageBody({super.key});

  @override
  ConsumerState<MyPageBody> createState() => _MyPageBodyState();
}

class _MyPageBodyState extends ConsumerState<MyPageBody> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authNotifierProvider);
    final user = authUser.user;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SocialLoginPage()),
                (Route<dynamic> route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    final userBase64 = base64ToBytes(user.profileImageUrl);

    const Color primaryColor = Color(0xFFF96666);
    const Color profileAvatarColor = Color(0xFFF5E6E6);
    const Color accentColor = Color(0xFFFFF7F7);
    const Color lightGrey = Color(0xFFFFFFFF);
    const Color secondaryTextColor = Color(0xFFB5A1A1);

    return SingleChildScrollView(
      primary: true,
      child: Container(
        color: lightGrey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          if (userBase64 != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: profileAvatarColor,
                              child: ClipOval(
                                child: Image.memory(
                                  userBase64,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: profileAvatarColor,
                              child: const Icon(Icons.person,
                                  size: 60, color: Colors.white),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomWidget.buildTitle(
                        user.name ?? "사용자 이름",
                        size: 18,
                        weight: FontWeight.w200,
                      ),
                      const SizedBox(height: 5),
                      CustomWidget.buildTitle(
                        "전포동 #22",
                        size: 14,
                        color: secondaryTextColor,
                        weight: FontWeight.w200,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          int tempUserRating = 3;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyProfileBody(
                                user: user,
                                userRating: tempUserRating,
                              ),
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
              ),
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
                      Icon(Icons.paid_outlined, size: 32, color: primaryColor),
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
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesListScreen(),
                          ),
                        );
                      },
                      child: _buildIconButton(
                        icon: Icons.shopping_bag_outlined,
                        text: "판매 내역",
                        color: accentColor,
                        iconColor: primaryColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PurchaseListScreen(),
                          ),
                        );
                      },
                      child: _buildIconButton(
                        icon: Icons.shopping_cart_outlined,
                        text: "구매 내역",
                        color: accentColor,
                        iconColor: primaryColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteListScreen(),
                          ),
                        );
                      },
                      child: _buildIconButton(
                        icon: Icons.favorite_border,
                        text: "관심 목록",
                        color: accentColor,
                        iconColor: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),
              _buildMenuTile(
                icon: Icons.my_location_outlined,
                text: "내 동네 설정",
              ),
              _buildMenuTile(
                icon: Icons.check_circle_outline,
                text: "신고 내역",
              ),
              _buildMenuTile(
                icon: Icons.search_outlined,
                text: "키워드 등록",
              ),
              const Divider(height: 30),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QnaScreen(),
                    ),
                  );
                },
                child: _buildMenuTile(
                  icon: Icons.headphones_outlined,
                  text: "고객 센터",
                  showArrow: true,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NoticeScreen(),
                    ),
                  );
                },
                child: _buildMenuTile(
                  icon: Icons.announcement_outlined,
                  text: "공지 사항",
                  showArrow: true,
                ),
              ),
              InkWell(
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SocialLoginPage()),
                          (Route<dynamic> route) => false,
                    );
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