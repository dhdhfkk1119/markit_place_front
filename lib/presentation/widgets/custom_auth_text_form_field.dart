import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

class CustomAuthTextFormField extends StatelessWidget {
  final String title;
  final String? errorText;
  final Function(String)? onChanged;
  final bool obscureText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomAuthTextFormField({
    super.key,
    required this.title,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
    this.hintText,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // theme.inputDecorationTheme을 기반으로 InputDecoration 객체를 생성합니다.
    final InputDecoration defaultInputDecoration =
        const InputDecoration().applyDefaults(theme.inputDecorationTheme);

    // 필요한 부분(hintText, errorText)만 수정하여 최종 InputDecoration 객체를 만듭니다.
    final InputDecoration effectiveDecoration = defaultInputDecoration.copyWith(
      hintText: hintText ?? "Enter $title",
      errorText: errorText, // errorText가 null이면 자동으로 에러 표시 없음
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: xSmall),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: effectiveDecoration,
          validator: validator,
        ),
      ],
    );
  }
}
