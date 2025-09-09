import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/widgets/custom_logo.dart';

import 'social_login_form.dart';

class SocialLoginBody extends StatelessWidget {
  const SocialLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF6F2),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            CustomLogo("Markit Place", "언제 어디서나 즐겁게 거래해요", "CookieRun"),
            SocialLoginForm()
          ],
        ),
      ),
    );
  }
}
