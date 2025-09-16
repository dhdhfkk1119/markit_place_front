import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 만약 사용한다면 주석 해제
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
  // .env 파일 로드 (flutter_dotenv 패키지 사용 시)
  // await dotenv.load(fileName: ".env"); // 필요시 주석 해제

  // Flutter 바인딩 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderContainer 생성 (Riverpod)
  final container = ProviderContainer();

  // AuthNotifier 인스턴스 가져오기
  final authNotifier = container.read(authNotifierProvider.notifier);

  // 수정된 setupInterceptors 함수에 authNotifier 인스턴스 전달
  setupInterceptors(authNotifier);

  // runApp 호출 시 UncontrolledProviderScope 사용
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  // StatelessWidget에서 ConsumerWidget으로 변경
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef 추가
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      routes: {
        "/main": (context) => const MainScreen(),
        "/register": (context) => const RegisterPage(),
        "/terms": (context) => const TermsPage(),
        "/social-login": (context) => const SocialLoginPage(),
        "/account-login": (context) => const AccountLoginPage(),
        "/find-account": (context) => const FindAccountPage(),
        "product/list": (context) => const ProductListPage(),
      },
    );
  }
}
