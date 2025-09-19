import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget 사용을 위해 추가
import '../../../../domain/members/providers/member_auth_provider.dart'; // AuthNotifierProvider 사용을 위해 추가
import '../../../../_core/constants/assets.dart';
import 'widgets/social_login_body.dart';

// 소셜 로그인 페이지를 정의하는 위젯
class SocialLoginPage extends ConsumerWidget {
  // StatelessWidget에서 ConsumerWidget으로 변경
  const SocialLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef ref 추가
    // 인증 상태를 감시하고, 이미 로그인된 상태이면 메인 화면으로 리디렉션
    final authState = ref.watch(authNotifierProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.status == AuthStatus.authenticated) {
        // 현재 라우트가 SocialLoginPage일 경우에만 네비게이션을 수행하여 중복 네비게이션 방지
        if (ModalRoute.of(context)?.settings.name == '/social-login' ||
            ModalRoute.of(context)?.settings.name == '/') {
          Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
        }
      }
    });

    // 만약 인증 상태가 이미 authenticated이면, 로딩 인디케이터나 빈 화면을 잠깐 보여줄 수 있음
    // 또는 SocialLoginBody를 보여주기 전에 리디렉션이 발생할 것으로 예상됨
    if (authState.status == AuthStatus.authenticated) {
      // 이미 로그인된 상태에서는 SocialLoginBody를 렌더링하기 전에 리디렉션되므로
      // 빈 컨테이너나 로딩 인디케이터를 반환하여 UI 깜빡임을 줄일 수 있습니다.
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // 또는 const SizedBox.shrink()
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:
            Text('로그인', style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey.shade300,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: const SocialLoginBody(),
    );
  }
}
