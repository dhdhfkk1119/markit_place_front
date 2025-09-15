import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/assets.dart'; // Assets.Fonts.cookieRun 사용 위함
import 'package:markit_place_front/_core/constants/size.dart'; // 필요시 size 상수 사용

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const AppTextFormField({
    Key? key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    this.helperText,
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 기본 스타일 정의 (RegisterForm의 _buildTextFormField 스타일 참고)
    TextStyle defaultLabelStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black87);
    final TextStyle defaultHelperStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun, color: Colors.grey.shade700);
    TextStyle defaultErrorStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun,
        color: Colors.redAccent,
        fontWeight: FontWeight.bold);
    // 입력 텍스트 스타일도 동일 폰트로 지정 (선택적)
    TextStyle inputTextStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: defaultLabelStyle,
        helperText: helperText,
        helperStyle: defaultHelperStyle,
        errorStyle: defaultErrorStyle,
        suffixIcon: suffixIcon,
        // 필요에 따라 테두리 등 추가적인 기본 InputDecoration 속성 설정 가능
        // 예: border: OutlineInputBorder(borderRadius: BorderRadius.circular(small)),
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      validator: validator,
      style: inputTextStyle, // 입력되는 텍스트에도 폰트 적용
      onTap: onTap,
      onChanged: onChanged,
    );
  }
}
