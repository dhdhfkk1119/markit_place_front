import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

// 비밀번호 초기화 폼 위젯
class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: 컨트롤러, 폼 키, 유효성 검사, 버튼 로직 등 구체적인 기능 구현 필요

    return Padding(
      padding: const EdgeInsets.all(medium), // 공통 여백 적용
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
        children: [
          const SizedBox(height: medium),
          const Text(
            '가입 시 사용한 아이디 또는 이메일을 입력해주세요.',
            // style: theme.textTheme.bodyLarge, // 필요시 테마 텍스트 스타일 적용
          ),
          const SizedBox(height: medium),
          TextFormField(
            decoration: const InputDecoration(
              hintText: '아이디 또는 이메일 입력',
              // 테마의 InputDecorationTheme이 기본적으로 적용됨
            ),
            // validator: (value) { ... }, // TODO: 유효성 검사 추가
          ),
          const SizedBox(height: xLarge),
          ElevatedButton(
            // 스타일은 theme.elevatedButtonTheme 에서 대부분 가져옴
            onPressed: () {
              // TODO: 비밀번호 초기화 로직 (재설정 링크 발송 등)
              print('비밀번호 재설정 버튼 클릭됨 (입력값 확인 필요)');
            },
            child: const Text('비밀번호 재설정 메일 발송'),
          ),
        ],
      ),
    );
  }
}
