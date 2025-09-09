import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'register_form.dart';

// 회원가입 페이지의 주요 레이아웃을 담당하는 위젯입니다.
class RegisterBody extends StatelessWidget {
  const RegisterBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
