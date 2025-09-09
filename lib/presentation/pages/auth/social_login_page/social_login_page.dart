import 'package:flutter/material.dart';

import 'widgets/social_login_body.dart';

class SocialLoginPage extends StatelessWidget {
  const SocialLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SocialLoginBody(),
    );
  }
}
