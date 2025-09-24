import 'dart:convert'; // for base64Decode
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/members/models/session_user.dart'; // SessionUser
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../auth/social_login_page/social_login_page.dart';
// import '../../../../../../domain/profile/profile_info_dto.dart'; // SessionUser로 대체 고려
// import '../../../../../../domain/profile/profile_provider.dart'; // profileInfoFutureProvider 사용 중단 고려

import '../../../report/list_page/report_list_page.dart';
import '../../my_profile_page/widgets/my_profile_body.dart';
import '../favorite_list_screen.dart';
import '../notice_screen.dart';
import '../purchase_list_screen.dart';
import '../qna_screen.dart';
import '../sales_list_screen.dart';

final _logger = Logger();

class MyPageBody extends ConsumerWidget {
  // ConsumerStatefulWidget -> ConsumerWidget
  const MyPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef ref 추가
    final authState = ref.watch(authNotifierProvider);
    final SessionUser? currentUser = authState.user;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ConsumerWidget에서는 mounted를 직접 사용할 수 없으므로 Navigator.of(context).mounted 사용
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

    // 이름 결정: SessionUser의 name 필드 사용
    final String profileName = currentUser.name ?? '이름 없음';

    // 이미지 결정 (Base64 우선, 다음 URL)
    ImageProvider? finalProfileImageProvider;

    if (currentUser.profileImageBase64 != null &&
        currentUser.profileImageBase64!.isNotEmpty) {
      String base64String = currentUser.profileImageBase64!;
      // 데이터 URI 스킴과 실제 URL이 섞여있는 경우를 방지 (e.g., data:image/png;base64,https://...)
      if (base64String.startsWith('data:image') &&
          base64String.contains('https://')) {
        _logger.w(
            '[MyPageBody] Invalid Base64 string detected (contains https): $base64String');
        // 이 경우 profileImageUrl을 사용하도록 유도 (아래 else if 블록에서 처리)
        base64String = ''; // 유효하지 않으므로 비움
      }

      if (base64String.isNotEmpty) {
        try {
          if (base64String.startsWith('data:image')) {
            base64String = base64String.split(',').last;
          }
          final bytes = base64Decode(base64String);
          finalProfileImageProvider = MemoryImage(bytes);
          _logger.d(
              '[MyPageBody] Using MemoryImage from SessionUser.profileImageBase64');
        } catch (e) {
          _logger.w(
              '[MyPageBody] Failed to decode SessionUser.profileImageBase64 (cleaned): $e');
          // 디코딩 실패 시 다음 단계 (URL)로 넘어감
        }
      }
    }

    if (finalProfileImageProvider == null &&
        currentUser.profileImageUrl != null &&
        currentUser.profileImageUrl!.isNotEmpty) {
      String imageUrl = currentUser.profileImageUrl!;
      // URL 필드에 실수로 데이터 URI가 들어간 경우 처리
      if (imageUrl.startsWith('data:image')) {
        _logger.w('[MyPageBody] profileImageUrl contains data URI: $imageUrl');
        if (imageUrl.contains('https://')) {
          // 데이터 URI 내부에 URL이 있는 잘못된 경우
          _logger.w(
              '[MyPageBody] Invalid data URI in profileImageUrl (contains https), attempting to extract URL');
          try {
            Uri uri =
                Uri.parse(imageUrl.substring(imageUrl.indexOf('https://')));
            if (uri.isAbsolute) {
              imageUrl = uri.toString();
              _logger.d('[MyPageBody] Extracted URL from data URI: $imageUrl');
            } else {
              imageUrl = ''; // 유효한 URL 추출 실패
            }
          } catch (e) {
            _logger.e('[MyPageBody] Error parsing URL from data URI: $e');
            imageUrl = '';
          }
        } else {
          // 순수 데이터 URI인 경우 (URL 필드에 있으면 안됨)
          try {
            String base64Part = imageUrl.split(',').last;
            final bytes = base64Decode(base64Part);
            finalProfileImageProvider = MemoryImage(bytes);
            _logger.d(
                '[MyPageBody] Using MemoryImage from profileImageUrl (data URI)');
            imageUrl = ''; // MemoryImage를 사용했으므로 URL은 비움
          } catch (e) {
            _logger.w(
                '[MyPageBody] Failed to decode data URI in profileImageUrl: $e');
            imageUrl = '';
          }
        }
      }

      if (imageUrl.isNotEmpty) {
        if (imageUrl.startsWith('http')) {
          finalProfileImageProvider = NetworkImage(imageUrl);
          _logger.d(
              '[MyPageBody] Using NetworkImage from SessionUser.profileImageUrl: $imageUrl');
        } else {
          _logger.w(
              '[MyPageBody] Invalid profileImageUrl (not http/https): $imageUrl');
        }
      }
    }

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
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: profileAvatarColor,
                            backgroundImage: finalProfileImageProvider,
                            child: finalProfileImageProvider == null
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.white70)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(profileName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      CustomWidget.buildTitle(
                        "동네 정보 없음",
                        size: 14,
                        color: secondaryTextColor,
                        weight: FontWeight.w200,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          int tempUserRating = currentUser.mannerScore ?? 3;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyProfileBody(
                                user: currentUser,
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
                                color: Color.fromRGBO(0, 0, 0, 0.05),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
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
              color: Color.fromRGBO(0, 0, 0, 0.05),
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
