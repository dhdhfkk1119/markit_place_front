import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/providers/auth_form/SessionNotifier.dart';
import 'package:markit_place_front/presentation/widgets/custom_text_form_field.dart';
import 'package:markit_place_front/presentation/widgets/custom_elevated_button.dart'; // CustomElevatedButton 임포트
import '../../../../widgets/snackbar_util.dart';

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
  bool _isLoadingLogin = false; // 로그인 로딩 상태 변수 추가

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: medium),
          const Center(
            child: Text(
              'Markit Place',
              style: TextStyle(
                  fontSize: large,
                  fontWeight: FontWeight.bold,
                  fontFamily: "CookieRun"),
            ),
          ),
          const SizedBox(height: xLarge),
          CustomTextFormField(
            controller: _idController,
            decoration: const InputDecoration(
              labelText: '아이디',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '아이디를 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: medium),
          CustomTextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요.';
              }
              return null;
            },
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
              const Text('자동 로그인', style: TextStyle(fontFamily: "CookieRun")),
            ],
          ),
          const SizedBox(height: medium),
          CustomElevatedButton(
            text: '로그인',
            isLoading: _isLoadingLogin,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoadingLogin = true;
                });
                final sessionNotifier = ref.read(sessionProvider.notifier);
                final result = await sessionNotifier.login(
                    _idController.text, _passwordController.text,
                    autoLogin: _autoLogin);

                if (!mounted) return;
                setState(() {
                  _isLoadingLogin = false;
                });

                if (result["success"] == true) {
                  SnackBarUtil.showSuccess(context, "성공했습니다");
                  Navigator.pushReplacementNamed(context, "/main");
                } else {
                  SnackBarUtil.showError(context, "로그인 실패");
                }
              }
            },
          ),
          const SizedBox(height: medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('회원가입',
                    style: TextStyle(
                        color: Colors.black54, fontFamily: "CookieRun")),
              ),
              const Text('|',
                  style: TextStyle(
                      color: Colors.black54, fontFamily: "CookieRun")),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/find-account');
                },
                child: const Text('아이디 / 비밀번호 찾기', // 텍스트 통합
                    style: TextStyle(
                        color: Colors.black54, fontFamily: "CookieRun")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
