import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'register_form.dart';

// 회원가입 페이지의 본문 레이아웃을 담당하는 위젯
class RegisterBody extends StatelessWidget {
  const RegisterBody({super.key});

  @override
  Widget build(BuildContext context) {
    // 페이지 전체 여백
    return Container(
      // 최상위 위젯을 Container로 감싸고 색상 적용
      color: const Color(0xFFFAF6F2),
      child: Padding(
        padding: const EdgeInsets.all(medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 자식 위젯들을 왼쪽으로 정렬
          children: [
            // 스크롤 가능한 영역을 최대화하기 위해 Expanded 사용
            Expanded(
              child: ListView(
                // 일반적으로 회원가입 폼은 내용이 길어질 수 있으므로 ListView 사용
                children: const [
                  // 회원가입 입력 필드 및 관련 로직을 포함하는 폼 위젯
                  RegisterForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
