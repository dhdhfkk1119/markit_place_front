import 'package:flutter/material.dart';

// 재사용 가능한 위젯으로 설계 하기 위함
// 맞춤 기능을 추가 하기 위해 재 설계 한다.
class CustomTextFormField extends StatelessWidget {
  final String? hint;
  final bool obscureText;
  final TextEditingController controller; // 입력 받은 값을 가져올수있음
  final String? initValue; // 초기 값 - 글 쓰기
  final String? Function(String?)? validator; // 유효성 검사
  final InputDecoration? decoration;

  const CustomTextFormField({
    Key? key,
    this.hint,
    this.obscureText = false,
    required this.controller,
    this.initValue = "",
    this.validator, // 선택적 매개 변수 (옵션값) - 유효성 검사
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initValue != null && initValue!.isNotEmpty) {
      controller.text = initValue!;
    }

    final mergedDecoration = InputDecoration(
      hintText: "Enter $hint",
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ).copyWith(
      border: decoration?.border,
      labelText: decoration?.labelText,
      hintText: decoration?.hintText ?? "Enter $hint",
      prefixIcon: decoration?.prefixIcon,
      suffixIcon: decoration?.suffixIcon,
    );

    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: obscureText,
      decoration: mergedDecoration,
    );
  }
}
