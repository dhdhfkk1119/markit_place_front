import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

class CustomAuthTextFormField extends StatelessWidget {
  final String title; // 라벨 제목
  final String errorText; // 검증 실패시 표시될 에러 메세지
  final Function(String)? onChanged; // 사용자 입력값이 변경될 때 호출되는 콜백 함수
  final bool obscureText;

  CustomAuthTextFormField({
    required this.title,
    this.errorText = "",
    this.onChanged,
    this.obscureText = false,
  }); // 입력값 숨길지 여부 설정

  @override
  Widget build(BuildContext context) {
    // CustomAuthTextFormField가 사용할 독립적인 테두리 색상을 정의합니다.
    // 이는 theme.dart의 InputDecorationTheme과 다를 수 있습니다.
    final Color defaultBorderColor = Colors.grey.shade600; // 일반 상태 테두리 색
    final Color focusedBorderColor =
        Theme.of(context).primaryColor; // 포커스 시 테두리 (예: 기본 파란색 계열)
    final Color errorBorderColor = Colors.red; // 에러 시 테두리 색 (기본 빨간색)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: fiveGap),
        TextFormField(
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: "Enter $title",
            errorText: errorText.isEmpty ? null : errorText,
            // === 테두리 스타일 완전 복원 시작 ===
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: defaultBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: errorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: errorBorderColor, width: 2.0),
            ),
            // === 테두리 스타일 완전 복원 끝 ===
          ),
        ),
      ],
    );
  }
}
