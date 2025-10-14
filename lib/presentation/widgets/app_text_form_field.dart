import 'package:flutter/material.dart';
import '../../_core/constants/assets.dart'; // Assets.Fonts.cookieRun 사용 위함
import '../../_core/constants/size.dart'; // 필요시 size 상수 사용

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String? helperText;
  final TextStyle? helperStyle; // helperStyle 파라미터 추가
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode? autovalidateMode;

  const AppTextFormField({
    Key? key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    this.helperText,
    this.helperStyle, // 생성자에 추가
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.autovalidateMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultHelperStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun, color: Colors.grey.shade700);
    TextStyle defaultErrorStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun,
        color: Colors.redAccent,
        fontWeight: FontWeight.bold);
    TextStyle inputTextStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            fontFamily: Assets.Fonts.cookieRun, color: Colors.black87),
        helperText: helperText,
        helperStyle: helperStyle ?? defaultHelperStyle, // 외부에서 받은 스타일 적용
        errorStyle: defaultErrorStyle,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      validator: validator,
      style: inputTextStyle,
      onTap: onTap,
      onChanged: onChanged,
      autovalidateMode: autovalidateMode,
    );
  }
}
