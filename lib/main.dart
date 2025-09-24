import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '_core/utils/my_http.dart';
import 'presentation/pages/auth/find_account_page/find_account_page.dart';
import 'presentation/pages/auth/register_page/register_page.dart';
import 'presentation/pages/auth/social_login_page/social_login_page.dart';
import 'presentation/pages/auth/terms_page/terms_page.dart';
import 'presentation/pages/index_stack_page/main_screen.dart';
import 'presentation/pages/index_stack_page/product/list_page/product_list_page.dart';
import '_core/utils/notification_util.dart';
import 'presentation/widgets/snackbar_util.dart';

// AuthNotifier import 추가
import 'domain/members/providers/member_auth_provider.dart';
import 'presentation/pages/auth/account_login_page/account_login_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
    onAuthFailed: (ex) {
      print("Naver Map Auth Failed: $ex");
      SnackBarUtil.showErrorGlobally(
          "네이버 지도 클라이언트 ID 인증에 실패했습니다. 관리자에게 문의해주세요.");
    },
  );

  await NotificationUtil.init();

  setupInterceptors(AuthNotifier());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // WidgetRef 추가
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: SocialLoginPage(),
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
