// D:/workspace-flutter/markit_place_front/lib/presentation/pages/auth/account_login_page/widgets/account_login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/size.dart';

import '../../../../../domain/members/providers/member_auth_provider.dart'; // authNotifierProvider 사용

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

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.text = 'user2';
    _passwordController.text = 'user1234';
    print(
        "[AccountLoginForm initState] Initial ID: ${_idController.text}, Initial PW: ${_passwordController.text}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authNotifier = ref.read(authNotifierProvider.notifier);
        print(
            "[AccountLoginForm initState - postFrameCallback] Updating Notifier with ID: ${_idController.text}");
        authNotifier.updateLoginInput(_idController.text);
        print(
            "[AccountLoginForm initState - postFrameCallback] Updating Notifier with PW: ${_passwordController.text}");
        authNotifier.updatePassword(_passwordController.text);
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/main");
        }
      } else if (next.status == AuthStatus.error &&
          (previous?.status != AuthStatus.error ||
              previous?.errorMessage != next.errorMessage)) {
        if (mounted) {
          SnackBarUtil.showError(context, next.errorMessage ?? "로그인에 실패했습니다.");
        }
      }
    });

    final loginFormState =
        ref.watch(authNotifierProvider.select((state) => state.loginFormModel));
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isLoading =
        ref.watch(authNotifierProvider.select((state) => state.status)) ==
            AuthStatus.loading;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(medium),
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
            onChanged: (value) {
              print("[AccountLoginForm ID onChanged] Value: $value");
              authNotifier.updateLoginInput(value);
            },
            decoration: InputDecoration(
              labelText: '아이디 또는 이메일',
              border: const OutlineInputBorder(),
              errorText: loginFormState.loginInputError.isEmpty
                  ? null
                  : loginFormState.loginInputError,
            ),
          ),
          const SizedBox(height: medium),
          CustomTextFormField(
            controller: _passwordController,
            onChanged: (value) {
              print("[AccountLoginForm PW onChanged] Value: $value");
              authNotifier.updatePassword(value);
            },
            decoration: InputDecoration(
              labelText: '비밀번호',
              border: const OutlineInputBorder(),
              errorText: loginFormState.passwordError.isEmpty
                  ? null
                  : loginFormState.passwordError,
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
            isLoading: isLoading,
            onPressed: () {
              final currentLoginInputFromController = _idController.text;
              final currentPasswordFromController = _passwordController.text;
              final currentLoginFormModel = authNotifier.state.loginFormModel;

              print(
                  "[LoginButton onPressed] Controller ID: $currentLoginInputFromController, Controller PW: $currentPasswordFromController");
              print(
                  "[LoginButton onPressed] AuthNotifier loginFormModel ID: ${currentLoginFormModel.loginInput}, PW: ${currentLoginFormModel.password}, ID Error: ${currentLoginFormModel.loginInputError}, PW Error: ${currentLoginFormModel.passwordError}");

              authNotifier.login();
            },
          ),
          const SizedBox(height: medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLInkGrey(
                text: '회원가입',
                onPressed: () {
                  authNotifier.resetLoginForm();
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
