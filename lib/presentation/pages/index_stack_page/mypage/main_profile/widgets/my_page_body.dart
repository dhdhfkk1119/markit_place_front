import 'dart:convert'; // for base64Decode
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <<< SVG 사용을 위해 추가
import 'package:logger/logger.dart';

import '../../../../../../_core/constants/assets.dart'; // <<< Assets 경로 사용을 위해 추가
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/members/models/session_user.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../auth/social_login_page/social_login_page.dart';

import '../../../report/list_page/report_list_page.dart';
import '../../my_profile_page/widgets/my_profile_body.dart';
import '../favorite_list_screen.dart';
import '../notice_screen.dart';
import '../purchase_list_screen.dart';
import '../qna_screen.dart';
import '../sales_list_screen.dart';

final _logger = Logger();

class MyPageBody extends ConsumerWidget {
  const MyPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final SessionUser? currentUser = authState.user;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SocialLoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    final String profileName = currentUser.name ?? '이름 없음';
    final String? provider = currentUser.provider?.toUpperCase(); // 비교를 위해 대문자로

    // 프로필 아바타 위젯 결정 로직
    Widget profileAvatarWidget;

    if (provider == "GOOGLE" || provider == "NAVER") {
      // 소셜 로그인 사용자
      if (currentUser.profileImageUrl != null &&
          currentUser.profileImageUrl!.isNotEmpty &&
          currentUser.profileImageUrl!.startsWith('http')) {
        // CircleAvatar의 backgroundImage는 errorBuilder를 직접 지원하지 않으므로,
        // Image.network를 child로 사용하고 errorBuilder를 구성하는 방식으로 변경
        profileAvatarWidget = ClipOval(
          child: Image.network(
            currentUser.profileImageUrl!,
            width: 100, // CircleAvatar radius * 2
            height: 100, // CircleAvatar radius * 2
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              _logger.w(
                  "Error loading social profile image ($provider): ${currentUser.profileImageUrl}, Error: $error");
              if (provider == "GOOGLE") {
                return SvgPicture.asset(Assets.Svgs.google,
                    fit: BoxFit.contain, width: 60, height: 60);
              } else if (provider == "NAVER") {
                return SvgPicture.asset(Assets.Svgs.naver,
                    fit: BoxFit.contain, width: 60, height: 60);
              }
              return const Icon(Icons.person,
                  size: 60, color: Colors.white70); // 기본 폴백
            },
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
      } else {
        // 소셜 프로필 URL이 없거나 유효하지 않은 경우 바로 SVG 표시
        _logger.d(
            "Social profile image URL is null or invalid for $provider. Displaying SVG.");
        if (provider == "GOOGLE") {
          profileAvatarWidget = CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(Assets.Svgs.google,
                  fit: BoxFit.contain, width: 70, height: 70));
        } else {
          // NAVER
          profileAvatarWidget = CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(Assets.Svgs.naver,
                  fit: BoxFit.contain, width: 70, height: 70));
        }
      }
    } else {
      // 일반 로그인 사용자 (MARKIT 또는 기타)
      ImageProvider? generalUserImageProvider;
      if (currentUser.profileImageBase64 != null &&
          currentUser.profileImageBase64!.isNotEmpty) {
        // Base64 이미지 처리 (기존 로직과 유사하게)
        String base64String = currentUser.profileImageBase64!;
        if (base64String.startsWith('data:image') &&
            base64String.contains('https://')) {
          base64String = ''; // 잘못된 형식 처리
        }
        if (base64String.isNotEmpty) {
          try {
            if (base64String.startsWith('data:image')) {
              base64String = base64String.split(',').last;
            }
            final bytes = base64Decode(base64String);
            generalUserImageProvider = MemoryImage(bytes);
          } catch (e) {
            _logger
                .w('[MyPageBody] Failed to decode Base64 for general user: $e');
          }
        }
      }

      if (generalUserImageProvider == null &&
          currentUser.profileImageUrl != null &&
          currentUser.profileImageUrl!.isNotEmpty &&
          currentUser.profileImageUrl!.startsWith('http')) {
        generalUserImageProvider = NetworkImage(currentUser.profileImageUrl!);
      }

      profileAvatarWidget = CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFFF5E6E6), // profileAvatarColor
        backgroundImage: generalUserImageProvider,
        child: generalUserImageProvider == null
            ? const Icon(Icons.person, size: 60, color: Colors.white70)
            : null,
      );
    }

    const Color primaryColor = Color(0xFFF96666);
    // const Color profileAvatarColor = Color(0xFFF5E6E6); // 위에서 직접 사용
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
                          // 수정된 프로필 아바타 위젯 사용
                          Container(
                            // ClipOval을 CircleAvatar처럼 보이게 하기 위한 컨테이너
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  const Color(0xFFF5E6E6), // 배경색 (이미지가 없을 때 등)
                            ),
                            child: profileAvatarWidget,
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(profileName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      CustomWidget.buildTitle(
                        "동네 정보 없음", // 이 부분은 추후 수정 필요
                        size: 14,
                        color: secondaryTextColor,
                        weight: FontWeight.w200,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          // MyProfileBody로 이동 시 provider 정보도 활용 가능
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyProfileBody(
                                user: currentUser, // SessionUser 전달
                                userRating: currentUser.mannerScore ?? 3,
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
                                color: const Color.fromRGBO(0, 0, 0, 0.05),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomWidget.buildTitle("프로필 보기",
                                size: 14, weight: FontWeight.w200),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ... (이하 코드 동일)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.05),
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
                          size: 32, color: primaryColor),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget.buildTitle("MP PAY",
                              size: 14, weight: FontWeight.w200),
                          CustomWidget.buildTitle("중고거래는 이제 MP페이를 이용해보세요!",
                              size: 14, weight: FontWeight.w200),
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
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SalesListScreen())),
                      child: _buildIconButton(
                          icon: Icons.shopping_bag_outlined,
                          text: "판매 내역",
                          color: accentColor,
                          iconColor: primaryColor),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const PurchaseListScreen())),
                      child: _buildIconButton(
                          icon: Icons.shopping_cart_outlined,
                          text: "구매 내역",
                          color: accentColor,
                          iconColor: primaryColor),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const FavoriteListScreen())),
                      child: _buildIconButton(
                          icon: Icons.favorite_border,
                          text: "관심 목록",
                          color: accentColor,
                          iconColor: primaryColor),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),
              _buildMenuTile(icon: Icons.my_location_outlined, text: "내 동네 설정"),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const ReportListPage())),
                child: _buildMenuTile(
                    icon: Icons.check_circle_outline, text: "신고 내역"),
              ),
              _buildMenuTile(icon: Icons.search_outlined, text: "키워드 등록"),
              const Divider(height: 30),
              InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const QnaScreen())),
                child: _buildMenuTile(
                    icon: Icons.headphones_outlined,
                    text: "고객 센터",
                    showArrow: true),
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NoticeScreen())),
                child: _buildMenuTile(
                    icon: Icons.announcement_outlined,
                    text: "공지 사항",
                    showArrow: true),
              ),
              InkWell(
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (Navigator.of(context).mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SocialLoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: _buildMenuTile(
                    icon: Icons.logout, text: "로그아웃", showArrow: true),
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
              color: color, borderRadius: BorderRadius.circular(30)),
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
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3)),
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
