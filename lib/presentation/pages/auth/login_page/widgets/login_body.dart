import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/auth/login_page/widgets/login_form.dart';
import 'package:markit_place_front/presentation/widgets/custom_logo.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [const CustomLogo("Markit Place"), LoginForm()],
      ),
    );
  }
}
