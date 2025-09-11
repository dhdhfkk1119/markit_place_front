// lib/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// secureStorage 인스턴스를 직접 사용
const secureStorage = FlutterSecureStorage();

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  void _checkTokenAndNavigate() async {
    final accessToken = await secureStorage.read(key: "accessToken");

    if (mounted) {
      if (accessToken != null) {
        Navigator.of(context).pushReplacementNamed("/main");
      } else {
        Navigator.of(context).pushReplacementNamed("/social-login");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
