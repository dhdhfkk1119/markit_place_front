import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

/// [CustomAuthTextFormField]
///
/// ## 목적
/// 인증 관련 폼의 텍스트 입력 필드 일관된 스타일 제공.
/// TextFormField 위 제목, 에러 메시지, 입력값 숨김 기능 지원.
/// 앱 전체 테마 InputDecorationTheme과 독립적인 테두리 스타일 적용.
///
/// ## 주요 사용처
/// - AccountLoginForm (아이디/이메일, 비밀번호 입력 필드)
/// - RegisterForm (사용자 이름, 비밀번호, 이메일 입력 필드 등)
/// - PasswordFindForm (구현 시)

// 인증 폼 전용 커스텀 TextFormField 위젯
class CustomAuthTextFormField extends StatelessWidget {
  final String title; // 제목
  final String errorText; // 에러 메시지
  final Function(String)? onChanged; // 입력값 변경 콜백
  final bool obscureText; // 입력값 숨김 여부

  // 생성자
  const CustomAuthTextFormField({
    super.key,
    required this.title,
    this.errorText = "",
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    // 테두리 색상 정의
    final Color defaultBorderColor = Colors.grey.shade600; // 일반 상태
    final Color focusedBorderColor = Theme.of(context).primaryColor; // 포커스 상태
    const Color errorBorderColor = Colors.red; // 에러 상태

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title), // 제목
        const SizedBox(height: tiny),
        TextFormField(
          onChanged: onChanged, // 입력 변경 콜백
          obscureText: obscureText, // 입력값 숨김 처리
          decoration: InputDecoration(
            hintText: "Enter $title", // 힌트 텍스트
            errorText: errorText.isEmpty ? null : errorText, // 에러 메시지
            // 테두리 스타일 정의 (인증 폼 고유 디자인)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(middle),
              borderSide: BorderSide(color: defaultBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(middle),
              borderSide: BorderSide(
                  color: focusedBorderColor, width: 2.0), // 포커스 시 테두리 두께 2.0
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(middle),
              borderSide: BorderSide(color: errorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(middle),
              borderSide: BorderSide(
                  color: errorBorderColor, width: 2.0), // 에러 + 포커스 시 테두리 두께 2.0
            ),
          ),
        ),
      ],
    );
  }
}
