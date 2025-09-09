import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/presentation/pages/auth/register_page/register_page.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/main_screen.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/list_page/product_list_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      routes: {
        "/register": (context) => const RegisterPage(),
        "product/list": (context) => const ProductListPage()
      },
    );
  }
}
