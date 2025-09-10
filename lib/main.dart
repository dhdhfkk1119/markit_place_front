import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/presentation/pages/auth/register_page/register_page.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/main_screen.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/product_list_page.dart';
import 'package:markit_place_front/presentation/pages/auth/social_login_page/social_login_page.dart';
import 'package:markit_place_front/presentation/pages/auth/terms_page/terms_page.dart'; // TermsPage 임포트 추가

import 'presentation/pages/auth/account_login_page/account_login_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SocialLoginPage(), // home을 SocialLoginPage로 변경
      routes: {
        "/register": (context) => const RegisterPage(), // 회원가입
        "/social-login": (context) => const SocialLoginPage(), // 소셜로긴
        "/account-login": (context) => const AccountLoginPage(), // 계정로긴
        "/terms": (context) => const TermsPage(), // 약관동의
        "product/list": (context) => const ProductListPage(), // 상품리스트
      },
    );
  }
}
