import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import 'widgets/my_page_body.dart';
import 'widgets/my_profile_edit_page.dart';
import '../../../../../_core/constants/assets.dart';

class MyPage extends ConsumerWidget {
  // StatelessWidget에서 ConsumerWidget으로 변경
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef ref 추가
    // 현재 사용자 정보를 가져옵니다.
    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.user;

    // 소셜 로그인 사용자인지 확인합니다. (provider가 'GOOGLE' 또는 'NAVER'인 경우)
    final isSocialLoginUser =
        currentUser?.provider == 'GOOGLE' || currentUser?.provider == 'NAVER';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // '<' 아이콘 클릭 시 main_screen.dart로 이동합니다.
            Navigator.pushNamedAndRemoveUntil(
                context, '/main', (route) => false);
          },
        ),
        title: Text(
          '나의 MP 마당',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontFamily: Assets.Fonts.cookieRun,
          ),
        ),
        centerTitle: false,
        actions: [
          // 소셜 로그인 사용자가 아닐 경우에만 톱니바퀴 아이콘을 표시합니다.
          if (!isSocialLoginUser)
            IconButton(
              onPressed: () {
                // 톱니바퀴 버튼을 눌렀을 때 프로필 수정 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyProfileEditPage()),
                );
              },
              icon: const Icon(Icons.settings, color: Colors.grey),
            ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const MyPageBody(),
    );
  }
}
