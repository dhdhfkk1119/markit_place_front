import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback click;
  // 버튼 비활성화 추가하기 -> 연속 클릭으로 데이터 중복으로 들어가는 거 방지
  const CustomTextButton({super.key, required this.text, required this.click});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: click,
      child: Text(text,
          style: const TextStyle(
              color: Colors.black87, decoration: TextDecoration.underline)),
    );
  }
}
