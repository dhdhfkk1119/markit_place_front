import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_medium.dart';

import '../../../../../_core/constants/assets.dart';

class RegisterForm extends ConsumerStatefulWidget {
  final List<int> agreedTermIds;

  const RegisterForm({super.key, required this.agreedTermIds});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController(text: 'asdfasdf');
  final _passwordController = TextEditingController(text: 'asdfasdf');
  final _passwordConfirmController = TextEditingController(text: 'asdfasdf');
  final _emailController = TextEditingController(text: 'asdfasdf@gmail.com');
  final _verificationCodeController = TextEditingController(text: ''); // 초기값 비움

  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController();

  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  final List<String> _suggestedDomains = [
    'gmail.com',
    'naver.com',
    'kakao.com',
    'hanmail.net',
    'daum.net',
    'nate.com',
  ];

  // 각 버튼의 로딩 상태를 관리하기 위한 bool 변수
  bool _isSendingVerificationEmail = false;
  bool _isConfirmingVerificationCode = false;

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
    // 페이지 진입 시 이전 이메일 인증 상태 초기화 (선택적)
    // Future.microtask(() => ref.read(authNotifierProvider.notifier).resetEmailVerificationState());
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller.dispose();
    }
    for (final node in _allFocusNodes) {
      node.removeListener(() => _ensureVisible(node)); // 리스너 제거 추가
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureVisible(FocusNode node) {
    if (node.hasFocus && mounted && node.context != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && node.context != null && node.hasFocus) {
          // node.hasFocus 추가 체크
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
    final defaultLabelStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black87);
    final defaultHelperStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun, color: Colors.grey.shade700);
    final defaultErrorStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun,
        color: Colors.redAccent,
        fontWeight: FontWeight.bold);

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
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
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

  // "인증번호 전송" 버튼을 눌렀을 때 실행될 콜백 함수
  Future<void> _handleSendVerificationEmail() async {
    final email = _emailController.text;
    // 이메일 필드에 대한 간단한 유효성 검사 (정규식 사용)
    final emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");

    if (email.isEmpty || !emailRegExp.hasMatch(email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            // const 제거
            content: Text('유효한 이메일 주소를 입력해주세요.',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
      return;
    }

    setState(() {
      _isSendingVerificationEmail = true;
    });

    try {
      // AuthNotifier를 통해 인증번호 발송 요청
      await ref
          .read(authNotifierProvider.notifier)
          .requestEmailVerification(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            // const 제거
            content: Text('인증번호가 발송되었습니다. 이메일을 확인해주세요.',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증번호 발송 실패: ${e.toString()}',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingVerificationEmail = false;
        });
      }
    }
  }

  // "인증확인" 버튼을 눌렀을 때 실행될 콜백 함수
  Future<void> _handleConfirmVerificationCode() async {
    final email = _emailController.text;
    final code = _verificationCodeController.text;

    // 이메일 또는 인증 코드 필드가 비어 있는지 확인
    if (email.isEmpty || code.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            // const 제거
            content: Text('이메일과 인증번호를 모두 입력해주세요.',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
      return;
    }
    // 간단한 인증 코드 유효성 검사 (예: 6자리) - 실제 상세 검증은 서버에서!
    if (code.length != 6) {
      // 예시로 6자리로 가정
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            // const 제거
            content: Text('인증번호 6자리를 입력해주세요.',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
      return;
    }

    setState(() {
      _isConfirmingVerificationCode = true;
    });

    try {
      // AuthNotifier를 통해 인증 코드 확인 요청
      final isVerified = await ref
          .read(authNotifierProvider.notifier)
          .confirmEmailVerification(email, code);
      if (!mounted) return;

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              // const 제거
              content: Text('이메일 인증이 완료되었습니다.',
                  style: TextStyle(
                      fontFamily: Assets
                          .Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
        );
        _verificationCodeController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증 실패: ${e.toString()}',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConfirmingVerificationCode = false;
        });
      }
    }
  }

  // "가입하기" 버튼을 눌렀을 때 실행될 콜백 함수
  void _onRegisterButtonPressed() {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final currentAuthState = ref.read(authNotifierProvider);

    if (currentAuthState.status == AuthStatus.loading ||
        _isSendingVerificationEmail ||
        _isConfirmingVerificationCode) {
      return;
    }

    if (!currentAuthState.isEmailVerifiedForRegistration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            // const 제거
            content: Text('이메일 인증을 먼저 완료해주세요.',
                style: TextStyle(
                    fontFamily:
                        Assets.Fonts.cookieRun))), // Assets.Fonts.cookieRun 사용
      );
      return;
    }

    if (widget.agreedTermIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // const 제거
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
        isEmailVerified: currentAuthState.isEmailVerifiedForRegistration,
      );
      authNotifier.register(memberToRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final bool isEmailVerified = authState.isEmailVerifiedForRegistration;
    final cookieRunTextStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun); // const 제거
    final cookieRunBlackTextStyle = TextStyle(
        fontFamily: Assets.Fonts.cookieRun, color: Colors.black87); // const 제거

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          previous?.status != AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!, style: cookieRunTextStyle)),
        );
      } else if (next.status == AuthStatus.unauthenticated &&
          next.errorMessage != null &&
          next.errorMessage == "회원가입 성공! 로그인해주세요.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!, style: cookieRunTextStyle)),
        );
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ref
            .read(authNotifierProvider.notifier)
            .clearRegistrationSuccessMessage();
        ref.read(authNotifierProvider.notifier).resetEmailVerificationState();
      }
    });

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
                      helperText: '아이디는 4자 이상 20자 이하로 입력해주세요.',
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return '아이디를 입력해주세요.';
                        if (value.length < 4 || value.length > 20)
                          return '아이디는 4자 이상 20자 이하로 입력해주세요.';
                        if (value.contains(' ')) return '아이디에 공백을 포함할 수 없습니다.';
                        return null;
                      },
                      readOnly: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: '중복확인',
                      onPressed: () {/* TODO: 아이디 중복확인 API 연동 */},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: medium),
              _buildTextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                labelText: '비밀번호',
                obscureText: true,
                helperText: '비밀번호는 8자 이상 20자 이하로 입력해주세요.',
                validator: (value) {
                  if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                  if (value.length < 8 || value.length > 20)
                    return '비밀번호는 8자 이상 20자 이하이어야 합니다.';
                  return null;
                },
                readOnly: false,
              ),
              const SizedBox(height: medium),
              _buildTextFormField(
                controller: _passwordConfirmController,
                focusNode: _passwordConfirmFocusNode,
                labelText: '비밀번호 확인',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return '비밀번호를 다시 한번 입력해주세요.';
                  if (value != _passwordController.text)
                    return '비밀번호가 일치하지 않습니다.';
                  return null;
                },
                readOnly: false,
              ),
              const SizedBox(height: medium),
              CustomWidget.buildTitle("이메일 인증하기"),
              const SizedBox(height: small),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      labelText: '이메일 주소',
                      keyboardType: TextInputType.emailAddress,
                      helperText: '예: example@markit.com',
                      readOnly: isEmailVerified,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return '이메일 주소를 입력해주세요.';
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
                        if (!emailRegex.hasMatch(value))
                          return '유효한 이메일 형식이 아닙니다.';
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: '인증번호 전송',
                      isLoading: _isSendingVerificationEmail,
                      onPressed: _isSendingVerificationEmail || isEmailVerified
                          ? null
                          : _handleSendVerificationEmail,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: xSmall),
                child: Wrap(
                  spacing: small,
                  runSpacing: xSmall,
                  children: _suggestedDomains.map((domain) {
                    return OutlinedButton(
                      onPressed: isEmailVerified
                          ? null
                          : () => _onDomainSuggestionTap(domain),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: small, vertical: xSmall),
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(small),
                        ),
                      ),
                      child: Text(domain, style: cookieRunBlackTextStyle),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: medium),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _verificationCodeController,
                      focusNode: _verificationCodeFocusNode,
                      labelText: '인증번호',
                      helperText: '이메일로 전송된 인증번호 6자리를 입력해주세요.',
                      keyboardType: TextInputType.number,
                      readOnly: isEmailVerified,
                      validator: (value) {
                        if (!isEmailVerified &&
                            (value == null || value.isEmpty))
                          return '인증번호를 입력해주세요.';
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: isEmailVerified ? '인증완료' : '인증확인',
                      isLoading: _isConfirmingVerificationCode,
                      onPressed:
                          _isConfirmingVerificationCode || isEmailVerified
                              ? null
                              : _handleConfirmVerificationCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: xLarge),
              CustomButtonLarge(
                text: authState.status == AuthStatus.loading &&
                        !(_isSendingVerificationEmail ||
                            _isConfirmingVerificationCode)
                    ? '가입 처리 중...'
                    : (_isSendingVerificationEmail
                        ? '인증번호 전송중...'
                        : (_isConfirmingVerificationCode
                            ? '인증 확인중...'
                            : '가입하기')),
                onPressed: authState.status == AuthStatus.loading ||
                        widget.agreedTermIds.isEmpty ||
                        _isSendingVerificationEmail ||
                        _isConfirmingVerificationCode
                    ? null
                    : _onRegisterButtonPressed,
              ),
              const SizedBox(height: large),
            ],
          ),
        ),
      ),
    );
  }
}
