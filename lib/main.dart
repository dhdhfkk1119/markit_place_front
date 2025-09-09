import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/presentation/pages/auth/register_page/register_page.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/product_list_page.dart';
import 'package:markit_place_front/presentation/pages/auth/social_login_page/social_login_page.dart';

import 'presentation/pages/auth/account_login_page/account_login_page.dart'; // SocialLoginPage 임포트 추가

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
        "/register": (context) => const RegisterPage(),
        "/social-login": (context) => const SocialLoginPage(),
        "/account-login": (context) => const AccountLoginPage(),
        "product/list": (context) => const ProductListPage(),
      },
    );
  }
}
