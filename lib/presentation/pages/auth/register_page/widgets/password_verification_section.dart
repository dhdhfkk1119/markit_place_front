import 'package:flutter/material.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../widgets/app_text_form_field.dart';

class PasswordVerificationSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final FocusNode passwordFocusNode;
  final FocusNode passwordConfirmFocusNode;

  const PasswordVerificationSection({
    Key? key,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.passwordFocusNode,
    required this.passwordConfirmFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextFormField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          labelText: '비밀번호',
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요.';
            }
            if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[A-Za-z\d]{8,16}$')
                .hasMatch(value)) {
              return '비밀번호는 8~16자, 영문, 숫자를 포함해야 합니다.';
            }
            return null;
          },
        ),
        const SizedBox(height: small),
        AppTextFormField(
          controller: passwordConfirmController,
          focusNode: passwordConfirmFocusNode,
          labelText: '비밀번호 확인',
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호 확인을 입력해주세요.';
            }
            if (value != passwordController.text) {
              return '비밀번호가 일치하지 않습니다.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
