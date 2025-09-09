import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'register_form.dart';

// 회원가입 페이지 주요 레이아웃 위젯
class RegisterBody extends StatelessWidget {
  const RegisterBody({super.key});

  @override
  Widget build(BuildContext context) {
    // 전체 패딩 적용
    return Padding(
      padding: const EdgeInsets.all(middle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 자식 위젯 왼쪽 정렬
        children: [
          // 상단 구분선
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          const SizedBox(height: middle),
          // 스크롤 가능한 영역 확장
          Expanded(
            child: ListView(
              children: const [
                // 회원가입 폼 위젯
                RegisterForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
