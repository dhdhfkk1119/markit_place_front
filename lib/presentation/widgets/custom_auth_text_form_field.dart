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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: smallGap),
        TextFormField(
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: "Enter $title",
            errorText: errorText.isEmpty ? null : errorText,
            enabledBorder: OutlineInputBorder(
              // 3. 기본 TextFormField 디자인
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              // 4. 손가락 터치시 TextFormField 디자인
              borderRadius: BorderRadius.circular(20),
            ),
            errorBorder: OutlineInputBorder(
              // 5. 에러발생시 TextFormField 디자인
              borderRadius: BorderRadius.circular(20),
            ),
            focusedErrorBorder: OutlineInputBorder(
              // 6. 에러가 발생 후 손가락을 터치했을 때 TextFormField 디자인
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
