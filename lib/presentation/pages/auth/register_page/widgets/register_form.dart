import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../domain/members/models/member.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../domain/members/providers/email_verification_provider.dart';
import '../../../../../domain/members/providers/register_provider.dart'; // 추가
import '../../../../widgets/custom_button_large.dart';
import '../../../../widgets/custom_button_medium.dart';
import '../../../../../_core/constants/assets.dart';
import './email_verification_section.dart';
import '../../../../widgets/app_text_form_field.dart';

class RegisterForm extends ConsumerStatefulWidget {
  final List<int> agreedTermIds;
  const RegisterForm({super.key, required this.agreedTermIds});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController(text: 'user3');
  final _passwordController = TextEditingController(text: 'user1234');
  final _passwordConfirmController = TextEditingController(text: 'user1234');
  final _emailController = TextEditingController(text: 'user3@gmail.com');
  final _verificationCodeController = TextEditingController();

  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController();

  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  // 로컬 상태 변수들은 RegisterState를 통해 관리되도록 점진적으로 대체
  // bool _isCheckingId = false; // -> registerState.status
  // String _idCheckMessage = ''; // -> registerState.errorMessage
  // bool _isIdValidAndChecked = false; // -> registerState.isIdChecked && registerState.status == RegisterStatus.idAvailable
  // Color _idCheckMessageColor = Colors.grey; // -> registerState.status 기반

  final List<String> _suggestedDomains = [
    'gmail.com',
    'naver.com',
    'kakao.com',
    'hanmail.net',
    'daum.net',
    'nate.com',
  ];

  @override
  void initState() {
    super.initState();
    _allControllers = [
      _idController,
      _passwordController,
      _passwordConfirmController,
      _emailController,
      _verificationCodeController,
    ];
    _allFocusNodes = [
      _idFocusNode,
      _passwordFocusNode,
      _passwordConfirmFocusNode,
      _emailFocusNode,
      _verificationCodeFocusNode,
    ];
    for (final node in _allFocusNodes) {
      node.addListener(() => _ensureVisible(node));
    }
    _idController.addListener(() {
      // 아이디 변경 시, RegisterNotifier의 상태를 초기화하거나,
      // 중복 확인 메시지를 UI에서 직접 관리하지 않고 RegisterState에 의존하도록 변경
      // 현재는 이 리스너의 역할을 RegisterState.isIdChecked를 통해 간접적으로 처리
      final registerState = ref.read(registerNotifierProvider);
      if (registerState.isIdChecked == true ||
          (registerState.errorMessage != null &&
              registerState.errorMessage!.isNotEmpty)) {
        // 사용자가 ID를 수정하면 RegisterNotifier의 상태를 리셋할 수 있도록 함
        // ref.read(registerNotifierProvider.notifier).resetIdCheckStatus(); // 이런 메소드가 RegisterNotifier에 필요할 수 있음
        // 또는 build 메소드에서 ID 변경 시 자동으로 UI가 업데이트되도록 함
      }
    });
    print("[RegisterForm initState] agreedTermIds: ${widget.agreedTermIds}");
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller.dispose();
    }
    for (final node in _allFocusNodes) {
      node.removeListener(() => _ensureVisible(node));
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureVisible(FocusNode node) {
    if (node.hasFocus && mounted && node.context != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && node.context != null && node.hasFocus) {
          Scrollable.ensureVisible(
            node.context!,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? helperText,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return AppTextFormField(
      controller: controller,
      labelText: labelText,
      validator: validator,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      helperText: helperText,
      suffixIcon: suffixIcon,
      readOnly: readOnly,
    );
  }

  void _onDomainSuggestionTap(String domain) {
    String currentText = _emailController.text;
    final atSignIndex = currentText.indexOf('@');
    if (atSignIndex != -1) {
      currentText = currentText.substring(0, atSignIndex);
    }
    _emailController.text = '$currentText@$domain';
    _emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: _emailController.text.length),
    );
    _emailFocusNode.requestFocus();
  }

  Future<void> _checkIdAvailability() async {
    final idValue = _idController.text;
    if (idValue.isEmpty) {
      // UI는 RegisterState의 변화를 통해 업데이트되므로 직접적인 setState 호출 줄임
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디를 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    if (idValue.length < 4 || idValue.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디는 4자 이상 20자 이하로 입력해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    if (idValue.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디에 공백을 포함할 수 없습니다.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      return;
    }
    // RegisterNotifier 호출로 변경
    await ref
        .read(registerNotifierProvider.notifier)
        .checkIdAvailability(idValue);
    // 결과 처리는 RegisterState를 watch/listen하여 UI 업데이트 (build 메소드 및 listener)
  }

  void _onRegisterButtonPressed() {
    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    final currentRegisterState = ref.read(registerNotifierProvider);
    final emailVerificationState = ref.read(emailVerificationNotifierProvider);
    final authState = ref.read(authNotifierProvider); // 자동 로그인 시 사용

    if (currentRegisterState.status == RegisterStatus.loading ||
        authState.status == AuthStatus.loading) {
      return;
    }

    final idCheckState = ref.read(registerNotifierProvider);
    if (!(idCheckState.isIdChecked == true &&
        idCheckState.status == RegisterStatus.idAvailable)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디 중복 확인을 해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      _idFocusNode.requestFocus();
      return;
    }

    if (!emailVerificationState.isVerifiedForCurrentSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('이메일 인증을 먼저 완료해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      _emailFocusNode.requestFocus();
      return;
    }

    if (widget.agreedTermIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('약관 동의 정보가 올바르지 않습니다. 다시 시도해주세요.',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final memberToRegister = Member.forRegistration(
        loginId: _idController.text,
        password: _passwordController.text,
        email: _emailController.text,
        agreedTermIds: widget.agreedTermIds,
        isEmailVerified: emailVerificationState.isVerifiedForCurrentSession,
      );
      registerNotifier.register(memberToRegister);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('입력 내용을 다시 확인해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final registerState = ref.watch(registerNotifierProvider);
    final emailVerificationState = ref.watch(emailVerificationNotifierProvider);
    final bool isEmailVerified =
        emailVerificationState.isVerifiedForCurrentSession;

    final cookieRunTextStyle = TextStyle(fontFamily: Assets.Fonts.cookieRun);

    // AuthState 리스너 (로그인 성공 및 일반 에러 처리)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          (previous?.status != AuthStatus.error ||
              previous?.errorMessage != next.errorMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("로그인 오류: ${next.errorMessage!}",
                  style: cookieRunTextStyle)),
        );
      } else if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        if (ModalRoute.of(context)?.settings.name == '/register') {
          // 로그인 성공 시 이메일 인증 상태 초기화
          ref
              .read(emailVerificationNotifierProvider.notifier)
              .resetEmailVerificationState();
          Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
        }
      }
    });

    // RegisterState 리스너 (회원가입 결과 및 ID 중복확인 결과 관련 UI 피드백)
    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      // 회원가입 성공 처리
      if (previous?.status != RegisterStatus.success &&
          next.status == RegisterStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.successMessage ?? "회원가입 성공! 로그인해주세요.",
                  style: cookieRunTextStyle)),
        );
        ref.read(registerNotifierProvider.notifier).consumeMessages(); // 메시지 소비

        // EmailVerificationState 초기화 (회원가입 성공 시)
        ref
            .read(emailVerificationNotifierProvider.notifier)
            .resetEmailVerificationState();

        // 자동 로그인 시도 (AuthNotifier 사용)
        final authNotifier = ref.read(authNotifierProvider.notifier);
        authNotifier.updateLoginInput(_idController.text);
        authNotifier.updatePassword(_passwordController.text);
        authNotifier.login(); // AuthNotifier의 login() 호출
      }
      // 회원가입 실패 처리 (ID 중복확인 중 발생한 에러와 구분)
      else if (next.status == RegisterStatus.error &&
          next.isIdChecked != true) {
        if (next.errorMessage != null &&
            next.errorMessage!.isNotEmpty &&
            (previous?.errorMessage != next.errorMessage ||
                previous?.status != RegisterStatus.error)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("회원가입 오류: ${next.errorMessage!}",
                    style: cookieRunTextStyle)),
          );
          ref.read(registerNotifierProvider.notifier).consumeMessages();
        }
      }
      // ID 중복 확인 관련 메시지 (성공, 실패, 에러) - build 메소드에서 직접 처리하므로 여기서는 생략 가능
      // 또는 특정 액션(e.g., 포커스 이동)이 필요하면 여기서 처리
    });

    // UI 결정 로직 (RegisterState 직접 사용)
    bool isIdCheckInProgress = registerState.status == RegisterStatus.loading &&
        registerState.isIdChecked != true;
    bool isIdSuccessfullyChecked = registerState.isIdChecked == true &&
        registerState.status == RegisterStatus.idAvailable;
    String idFeedbackMessage = "";
    Color idFeedbackColor = Colors.grey;

    if (_idController.text.isNotEmpty) {
      // 아이디 입력시에만 피드백 메시지 표시
      if (registerState.status == RegisterStatus.idAvailable ||
          registerState.status == RegisterStatus.idUnavailable ||
          (registerState.status == RegisterStatus.error &&
              registerState.isIdChecked == true)) {
        idFeedbackMessage = registerState.errorMessage ?? "";
        if (registerState.status == RegisterStatus.idAvailable) {
          idFeedbackColor = Colors.green;
        } else {
          idFeedbackColor = Colors.red;
        }
      } else if (isIdCheckInProgress) {
        idFeedbackMessage = "확인 중...";
        idFeedbackColor = Colors.grey;
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.buildTitle("아이디/비밀번호 입력하기"),
              const SizedBox(height: small),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      labelText: '아이디',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요.';
                        }
                        if (value.length < 4 || value.length > 20) {
                          return '아이디는 4자 이상 20자 이하로 입력해주세요.';
                        }
                        if (value.contains(' ')) return '아이디에 공백을 포함할 수 없습니다.';
                        // 중복 확인 성공 여부 validator에 추가 가능 (선택적)
                        // if (!isIdSuccessfullyChecked) return '아이디 중복 확인을 해주세요.';
                        return null;
                      },
                      readOnly: isIdCheckInProgress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: '중복확인',
                      isLoading: isIdCheckInProgress,
                      onPressed:
                          isIdCheckInProgress ? null : _checkIdAvailability,
                    ),
                  ),
                ],
              ),
              if (idFeedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                  child: Text(
                    idFeedbackMessage,
                    style: TextStyle(
                      color: idFeedbackColor,
                      fontSize: 12.0,
                      fontFamily: Assets.Fonts.cookieRun,
                    ),
                  ),
                ),
              const SizedBox(height: small),
              _buildTextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                labelText: '비밀번호',
                obscureText: true,
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
              _buildTextFormField(
                controller: _passwordConfirmController,
                focusNode: _passwordConfirmFocusNode,
                labelText: '비밀번호 확인',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: medium),
              EmailVerificationSection(
                emailController: _emailController,
                verificationCodeController: _verificationCodeController,
                emailFocusNode: _emailFocusNode,
                verificationCodeFocusNode: _verificationCodeFocusNode,
                isEmailAlreadyVerified: isEmailVerified,
                suggestedDomains: _suggestedDomains,
                onDomainSuggestionTap: _onDomainSuggestionTap,
              ),
              const SizedBox(height: medium),
              CustomButtonLarge(
                text: '가입하기',
                isLoading: registerState.status == RegisterStatus.loading ||
                    authState.status == AuthStatus.loading,
                onPressed: _onRegisterButtonPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
