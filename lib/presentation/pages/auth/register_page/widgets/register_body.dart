import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart'; // 간격 사용을 위해 추가
import 'register_form.dart';

class RegisterBody extends StatelessWidget {
  const RegisterBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Align 위젯으로 감싸인 Text('회원 가입')과 아래 SizedBox(height: tenGap) 제거됨
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          const SizedBox(height: twenGap),
          Expanded(
            child: ListView(
              children: const [
                RegisterForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
