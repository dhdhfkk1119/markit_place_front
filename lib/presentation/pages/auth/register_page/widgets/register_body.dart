import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'register_form.dart';

class RegisterBody extends StatelessWidget {
  final List<int> agreedTermIds; // 생성자 파라미터 추가

  // 생성자 수정: agreedTermIds를 필수로 받도록 함
  const RegisterBody({super.key, required this.agreedTermIds});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF6F2),
      child: Padding(
        padding: const EdgeInsets.all(medium), // 'medium'은 size.dart에 정의 가정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  // RegisterForm에 agreedTermIds 전달
                  RegisterForm(agreedTermIds: agreedTermIds),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
