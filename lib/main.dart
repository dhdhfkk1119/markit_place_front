import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/utils/my_http.dart';
import 'package:markit_place_front/presentation/pages/auth/find_account_page/find_account_page.dart';
import 'package:markit_place_front/presentation/pages/auth/register_page/register_page.dart';
import 'package:markit_place_front/presentation/pages/auth/social_login_page/social_login_page.dart';
import 'package:markit_place_front/presentation/pages/auth/terms_page/terms_page.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/main_screen.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/product_list_page.dart';
import 'package:markit_place_front/presentation/pages/splash/splash_page.dart';

// AuthNotifier import 추가
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';
import 'presentation/pages/auth/account_login_page/account_login_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  _initNaverMap();
  setupInterceptors(AuthNotifier());
  runApp(const ProviderScope(child: MyApp()));
}

void _initNaverMap() async {
  await FlutterNaverMap().init(
      clientId: dotenv.env['NAVER_CLIENT_ID']!,
      onAuthFailed: (ex) {
        print("인증 실패: $ex");
      });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // WidgetRef 추가
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SocialLoginPage(),
      routes: {
        "/main": (context) => const MainScreen(),
        "/register": (context) => const RegisterPage(),
        "/terms": (context) => const TermsPage(),
        "/social-login": (context) => const SocialLoginPage(),
        "/account-login": (context) => const AccountLoginPage(),
        "/find-account": (context) => const FindAccountPage(),
        "/product/list": (context) => const ProductListPage(),
      },
    );
  }
}
