// D:/workspace-flutter/markit_place_front/lib/presentation/pages/auth/account_login_page/widgets/account_login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/size.dart';

// --- 사용하지 않는 Provider import 주석 처리 또는 삭제 ---
// import 'package:markit_place_front/domain/providers/auth_form/SessionNotifier.dart';
// import 'package:markit_place_front/domain/providers/auth_form/login_form_notifier.dart'; // 만약 있었다면

// --- 새로운 Provider import ---
import 'package:markit_place_front/domain/members/providers/member_login_form_provider.dart'; // 1단계에서 생성한 파일
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart'; // 기존 AuthNotifier

import 'package:markit_place_front/presentation/widgets/custom_text_form_field.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_link_grey.dart';
import 'package:markit_place_front/presentation/widgets/snackbar_util.dart';
import '../../../../../_core/constants/assets.dart';

class AccountLoginForm extends ConsumerStatefulWidget {
  const AccountLoginForm({super.key});

  @override
  ConsumerState<AccountLoginForm> createState() => _AccountLoginFormState();
}

class _AccountLoginFormState extends ConsumerState<AccountLoginForm> {
  // _formKey는 Form 위젯에 사용되므로 유지
  final _formKey = GlobalKey<FormState>();
  bool _autoLogin = false; // 자동 로그인 UI 상태

  // TextEditingController는 UI의 입력 필드와 직접 연결되므로 유지
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
    // AuthNotifier의 상태 변화 감지 (로그인 성공/실패 시 UI 피드백)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackBarUtil.showSuccess(context, "로그인 성공!");
        Navigator.pushReplacementNamed(context, "/main");
      } else if (next.status == AuthStatus.error) {
        SnackBarUtil.showError(context, next.errorMessage ?? "로그인에 실패했습니다.");
      }
    });

    // memberLoginFormProvider를 watch하여 입력 필드 에러 메시지 표시에 사용
    final loginFormState = ref.watch(memberLoginFormProvider);
    final loginFormNotifier = ref.read(memberLoginFormProvider.notifier);

    return Form(
      key: _formKey, // Form 위젯에 GlobalKey 연결
      child: ListView(
        children: [
          const SizedBox(height: medium),
          Center(
            // const 제거
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
            onChanged: (value) => loginFormNotifier
                .updateUsername(value), // 실시간 유효성 검사 및 에러 상태 업데이트
            decoration: InputDecoration(
              labelText: '아이디',
              border: const OutlineInputBorder(),
              errorText: loginFormState.usernameError.isEmpty
                  ? null
                  : loginFormState.usernameError,
            ),
          ),
          const SizedBox(height: medium),
          CustomTextFormField(
            controller: _passwordController,
            onChanged: (value) => loginFormNotifier
                .updatePassword(value), // 실시간 유효성 검사 및 에러 상태 업데이트
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
              Text('자동 로그인', // const 제거
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
            ],
          ),
          const SizedBox(height: medium),
          CustomButtonLarge(
            text: '로그인',
            isLoading:
                ref.watch(authNotifierProvider).status == AuthStatus.loading,
            onPressed: () {
              // 컨트롤러의 현재 값으로 Notifier 상태 업데이트 (onChanged가 이미 처리했을 수 있지만, 명시적 호출)
              loginFormNotifier.updateUsername(_idController.text);
              loginFormNotifier.updatePassword(_passwordController.text);

              // 폼 유효성 검사 (memberLoginFormProvider 사용)
              if (loginFormNotifier.validateForm()) {
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
                  ref.invalidate(memberLoginFormProvider); // 폼 상태 초기화
                  Navigator.pushNamed(context, '/terms');
                },
              ),
              const SizedBox(width: small),
              Text('|', // const 제거
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
