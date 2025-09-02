import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/login_page/widgets/login_form.dart';
import 'package:markit_place_front/presentation/widgets/custom_logo.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFAF6F2),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const CustomLogo("Markit Place", "언제 어디서나 즐겁게 거래해요", "CookieRun"),
            LoginForm()
          ],
        ),
      ),
    );
  }
}
