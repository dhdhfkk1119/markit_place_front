// D:/workspace-flutter/markit_place_front/lib/presentation/pages/auth/account_login_page/widgets/account_login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/size.dart';

// --- 새로운 Provider import ---
import '../../../../../domain/members/providers/member_login_form_provider.dart'; // 수정됨
import '../../../../../domain/members/providers/member_auth_provider.dart';

import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/custom_button_large.dart';
import '../../../../widgets/custom_link_grey.dart';
import '../../../../widgets/snackbar_util.dart';
import '../../../../../_core/constants/assets.dart';

class AccountLoginForm extends ConsumerStatefulWidget {
  const AccountLoginForm({super.key});

  @override
  ConsumerState<AccountLoginForm> createState() => _AccountLoginFormState();
}

class _AccountLoginFormState extends ConsumerState<AccountLoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _autoLogin = false;

  // 컨트롤러 변수명은 _idController로 유지해도 되나, 명확성을 위해 _loginInputController 등으로 변경도 고려 가능
  // 여기서는 _idController를 그대로 사용. 이 컨트롤러가 이제 아이디 또는 이메일 입력을 받음.
  final _idController = TextEditingController(text: 'user1');
  final _passwordController = TextEditingController(text: 'user1234');

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackBarUtil.showSuccess(context, "로그인 성공!");
        Navigator.pushReplacementNamed(context, "/main");
      } else if (next.status == AuthStatus.error) {
        SnackBarUtil.showError(context, next.errorMessage ?? "로그인에 실패했습니다.");
      }
    });

    final memberLoginFormState = ref.watch(memberLoginFormProvider);
    final memberLoginFormNotifier = ref.read(memberLoginFormProvider.notifier);

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: medium),
          Center(
            child: Text(
              'Markit Place',
              style: TextStyle(
                  fontSize: large,
                  fontWeight: FontWeight.bold,
                  fontFamily: Assets.Fonts.cookieRun),
            ),
          ),
          const SizedBox(height: xLarge),
          CustomTextFormField(
            controller: _idController,
            // 1. onChanged 콜백에서 updateLoginInput 호출로 변경
            onChanged: (value) =>
                memberLoginFormNotifier.updateLoginInput(value),
            decoration: InputDecoration(
              // 2. labelText 변경: "아이디" -> "아이디 또는 이메일"
              labelText: '아이디 또는 이메일',
              border: const OutlineInputBorder(),
              // 3. errorText를 loginInputError에서 가져오도록 변경
              errorText: memberLoginFormState.loginInputError.isEmpty
                  ? null
                  : memberLoginFormState.loginInputError,
            ),
          ),
          const SizedBox(height: medium),
          CustomTextFormField(
            controller: _passwordController,
            onChanged: (value) => memberLoginFormNotifier.updatePassword(value),
            decoration: InputDecoration(
              labelText: '비밀번호',
              border: const OutlineInputBorder(),
              errorText: memberLoginFormState.passwordError.isEmpty
                  ? null
                  : memberLoginFormState.passwordError,
            ),
            obscureText: true,
          ),
          const SizedBox(height: small),
          Row(
            children: [
              Checkbox(
                value: _autoLogin,
                onChanged: (bool? value) {
                  setState(() {
                    _autoLogin = value ?? false;
                  });
                },
              ),
              Text('자동 로그인',
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
            ],
          ),
          const SizedBox(height: medium),
          CustomButtonLarge(
            text: '로그인',
            isLoading:
                ref.watch(authNotifierProvider).status == AuthStatus.loading,
            onPressed: () {
              // 4. 로그인 버튼 클릭 시 updateLoginInput 호출로 변경
              memberLoginFormNotifier.updateLoginInput(_idController.text);
              memberLoginFormNotifier.updatePassword(_passwordController.text);

              if (memberLoginFormNotifier.validateForm()) {
                // login 메소드로 전달되는 _idController.text 값은 변경 없음
                // (이 값은 아이디 또는 이메일 문자열 그대로 전달됨)
                ref.read(authNotifierProvider.notifier).login(
                      _idController.text,
                      _passwordController.text,
                    );
              } else {
                SnackBarUtil.showError(context, "입력 내용을 확인해주세요.");
              }
            },
          ),
          const SizedBox(height: medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLInkGrey(
                text: '회원가입',
                onPressed: () {
                  ref.invalidate(memberLoginFormProvider);
                  Navigator.pushNamed(context, '/terms');
                },
              ),
              const SizedBox(width: small),
              Text('|',
                  style: TextStyle(
                      color: Colors.black54,
                      fontFamily: Assets.Fonts.cookieRun)),
              const SizedBox(width: small),
              CustomLInkGrey(
                text: '아이디 / 비밀번호 찾기',
                onPressed: () {
                  Navigator.pushNamed(context, '/find-account');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
