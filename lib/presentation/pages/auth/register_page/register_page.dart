import 'package:flutter/material.dart';
import 'widgets/register_body.dart';

import '../../../../_core/constants/assets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TermsPage로부터 전달받은 arguments (동의한 약관 ID 목록)
    final List<int>? agreedTermIds =
        ModalRoute.of(context)?.settings.arguments as List<int>?;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // TermsPage에서 pushReplacementNamed로 왔으므로, pop하면 SocialLoginPage로 감
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            // Navigator.pushReplacementNamed(context, '/social-login'); // 필요시 대체
          },
        ),
        title:
            Text('회원 가입', style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey.shade300,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      // RegisterBody에 agreedTermIds를 전달 (null이면 빈 리스트로)
      body: RegisterBody(agreedTermIds: agreedTermIds ?? []),
    );
  }
}
