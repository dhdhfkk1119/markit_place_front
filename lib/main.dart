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

// AuthNotifier import 추가
import 'domain/members/providers/member_auth_provider.dart';
import 'presentation/pages/auth/account_login_page/account_login_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// ProviderContainer? providerContainer; // 삭제

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // _init()은 여기서 호출하거나, MyApp 위젯 내부에서 한번만 호출되도록 조정 가능
  // 여기서는 우선 MyApp 위젯으로 옮기는 것을 가정하고 주석 처리
  // _init();

  // setupInterceptors 호출은 MyApp 위젯 내부로 이동

  runApp(
    const ProviderScope(
      // ProviderScope로 변경
      child: MyApp(),
    ),
  );
}

// _init 함수는 MyApp으로 이동하거나 앱 초기화 로직을 담당하는 별도의 Provider에서 관리 가능
// void _init() async { ... } // MyApp으로 이동 고려

class MyApp extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget으로 변경
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // State 클래스 생성
  @override
  void initState() {
    super.initState();
    // initState에서 AuthNotifier를 가져와 인터셉터 설정
    final authNotifier = ref.read(authNotifierProvider.notifier);
    setupInterceptors(authNotifier);
    _initializeAsyncDependencies(); // 비동기 초기화 함수 호출
  }

  // 비동기 초기화 로직 (기존 _init 함수의 내용)
  Future<void> _initializeAsyncDependencies() async {
    try {
      await FlutterNaverMap().init(
          clientId: dotenv.env['NAVER_CLIENT_ID']!,
          onAuthFailed: (ex) {
            print("네이버 지도 인증 실패: $ex");
          });
    } catch (e) {
      print("네이버 지도 초기화 중 오류: $e");
    }

    try {
      await NotificationUtil.init();
    } catch (e) {
      print("알림 유틸 초기화 중 오류: $e");
    }
    // 여기에 다른 비동기 초기화 로직 추가 가능
  }

  @override
  Widget build(BuildContext context) {
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
