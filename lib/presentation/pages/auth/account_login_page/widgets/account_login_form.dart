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

  // 컨트롤러는 UI의 상태를 직접 관리하므로 그대로 둡니다.
  // Notifier의 updateLoginInput/updatePassword를 통해 Notifier 상태와 동기화됩니다.
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 초기값을 설정하고 Notifier에도 반영합니다.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final authNotifier = ref.read(authNotifierProvider.notifier);
    //   // 개발 편의성을 위한 초기값 설정 (실제 배포 시에는 제거하거나 빈 문자열로)
    //   _idController.text = 'user1';
    //   _passwordController.text = 'user1234';
    //   authNotifier.updateLoginInput(_idController.text);
    //   authNotifier.updatePassword(_passwordController.text);
    // });
    // 기존 테스트용 초기값은 유지하되, 필요시 Notifier에도 초기 상태를 반영할 수 있습니다.
    // 단, 사용자가 직접 입력하기 전에 Notifier 상태를 초기화하는 것이 좋을 수 있습니다.
    // 여기서는 UI 컨트롤러에만 초기값을 두고, 사용자가 입력할 때 Notifier가 업데이트되도록 합니다.
    _idController.text = 'user1';
    _passwordController.text = 'user1234';
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AuthState 전체를 watch하고, 로그인 성공/실패 시 SnackBar 표시 및 화면 전환
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        // 로그인 성공 시 메시지는 선택 사항 (바로 화면 전환)
        // SnackBarUtil.showSuccess(context, "로그인 성공!");
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/main");
        }
      } else if (next.status == AuthStatus.error &&
          (previous?.status != AuthStatus.error ||
              previous?.errorMessage != next.errorMessage)) {
        // 에러 메시지가 변경되었거나, 처음 에러가 발생했을 때만 SnackBar 표시
        if (mounted) {
          SnackBarUtil.showError(context, next.errorMessage ?? "로그인에 실패했습니다.");
        }
      }
    });

    // 로그인 폼 상태(값, 에러)를 AuthState에서 가져옴
    final loginFormState =
        ref.watch(authNotifierProvider.select((state) => state.loginFormModel));
    // AuthNotifier 인스턴스 (메소드 호출용)
    final authNotifier = ref.read(authNotifierProvider.notifier);
    // 로딩 상태
    final isLoading =
        ref.watch(authNotifierProvider.select((state) => state.status)) ==
            AuthStatus.loading;

    // UI 컨트롤러의 텍스트가 Notifier 상태와 다를 경우, Notifier 상태를 우선하여 UI를 업데이트 (선택적)
    // 이는 Notifier 상태가 외부 요인(예: 자동로그인 실패 후 폼 초기화)에 의해 변경될 수 있기 때문입니다.
    // 하지만 일반적으로는 onChanged에서 Notifier를 업데이트하므로 이 코드는 불필요할 수 있습니다.
    // if (_idController.text != loginFormState.loginInput) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _idController.text = loginFormState.loginInput;
    //   });
    // }
    // if (_passwordController.text != loginFormState.password) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _passwordController.text = loginFormState.password;
    //   });
    // }

    return Form(
      key: _formKey, // _formKey는 이제 필수는 아님 (유효성 검사를 Notifier에서 하므로)
      child: ListView(
        padding: const EdgeInsets.all(medium), // 전체적인 패딩 추가
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
            controller: _idController, // UI 상태 관리용 컨트롤러
            onChanged: (value) =>
                authNotifier.updateLoginInput(value), // 입력 시마다 Notifier 상태 업데이트
            decoration: InputDecoration(
              labelText: '아이디 또는 이메일',
              border: const OutlineInputBorder(),
              errorText: loginFormState.loginInputError.isEmpty
                  ? null
                  : loginFormState.loginInputError, // Notifier의 에러 메시지 사용
            ),
          ),
          const SizedBox(height: medium),
          CustomTextFormField(
            controller: _passwordController, // UI 상태 관리용 컨트롤러
            onChanged: (value) =>
                authNotifier.updatePassword(value), // 입력 시마다 Notifier 상태 업데이트
            decoration: InputDecoration(
              labelText: '비밀번호',
              border: const OutlineInputBorder(),
              errorText: loginFormState.passwordError.isEmpty
                  ? null
                  : loginFormState.passwordError, // Notifier의 에러 메시지 사용
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
            isLoading: isLoading, // 로딩 상태 연결
            onPressed: () {
              // 로그인 버튼 클릭 시, 현재 컨트롤러 값을 Notifier에 한번 더 업데이트 (선택적이지만 안전함)
              // authNotifier.updateLoginInput(_idController.text);
              // authNotifier.updatePassword(_passwordController.text);

              // 유효성 검사 및 로그인은 Notifier에 위임
              // validateLoginForm() 내부에서 state가 업데이트 되므로, watch하고 있는 UI가 리빌드될 수 있음.
              // login() 메소드는 내부적으로 validateLoginForm()을 호출함.
              authNotifier.login();
              // login() 메소드에서 실패 시 SnackBar는 listen 콜백에서 처리됨
            },
          ),
          const SizedBox(height: medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLInkGrey(
                text: '회원가입',
                onPressed: () {
                  authNotifier.resetLoginForm(); // 회원가입 화면으로 가기 전 폼 상태 초기화
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
                  // 계정 찾기 화면으로 가기 전에도 폼 상태를 초기화할 수 있음 (선택적)
                  // authNotifier.resetLoginForm();
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
