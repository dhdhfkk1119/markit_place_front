import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/custom_widget.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../domain/members/models/member.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
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
  final _verificationCodeController = TextEditingController(text: 'user3');

  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController();

  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  bool _isCheckingId = false;
  String _idCheckMessage = '';
  bool _isIdValidAndChecked = false;
  Color _idCheckMessageColor = Colors.grey;

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
      if (_isIdValidAndChecked || _idCheckMessage.isNotEmpty) {
        setState(() {
          _isIdValidAndChecked = false;
          _idCheckMessage = '';
          _idCheckMessageColor = Colors.grey;
        });
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
      setState(() {
        _idCheckMessage = '아이디를 입력해주세요.';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
      return;
    }
    if (idValue.length < 4 || idValue.length > 20) {
      setState(() {
        _idCheckMessage = '아이디는 4자 이상 20자 이하로 입력해주세요.';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
      return;
    }
    if (idValue.contains(' ')) {
      setState(() {
        _idCheckMessage = '아이디에 공백을 포함할 수 없습니다.';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
      return;
    }
    setState(() {
      _isCheckingId = true;
      _idCheckMessage = '확인 중...';
      _idCheckMessageColor = Colors.grey;
    });
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final bool isAvailable = await authNotifier.checkIdAvailability(idValue);
      if (isAvailable) {
        setState(() {
          _idCheckMessage = '사용 가능한 아이디입니다.';
          _idCheckMessageColor = Colors.green;
          _isIdValidAndChecked = true;
        });
      } else {
        setState(() {
          _idCheckMessage = '이미 사용 중인 아이디입니다.';
          _idCheckMessageColor = Colors.red;
          _isIdValidAndChecked = false;
        });
      }
    } catch (e) {
      setState(() {
        _idCheckMessage = '오류: ${e.toString().split(': ').last}';
        _idCheckMessageColor = Colors.red;
        _isIdValidAndChecked = false;
      });
    } finally {
      setState(() {
        _isCheckingId = false;
      });
    }
  }

  void _onRegisterButtonPressed() {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final currentAuthState = ref.read(authNotifierProvider);

    if (currentAuthState.status == AuthStatus.loading) {
      return;
    }

    if (!_isIdValidAndChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('아이디 중복 확인을 해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
      _idFocusNode.requestFocus();
      return;
    }

    final freshAuthStateForEmailCheck = ref.read(authNotifierProvider);
    if (!freshAuthStateForEmailCheck.isEmailVerifiedForRegistration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('이메일 인증을 먼저 완료해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
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
      final freshAuthStateForRegister = ref.read(authNotifierProvider);
      final memberToRegister = Member.forRegistration(
        loginId: _idController.text,
        password: _passwordController.text,
        email: _emailController.text,
        agreedTermIds: widget.agreedTermIds,
        isEmailVerified:
            freshAuthStateForRegister.isEmailVerifiedForRegistration,
      );
      authNotifier.register(memberToRegister);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        // 추가: 폼 유효성 검사 실패 시 스낵바
        SnackBar(
            content: Text('입력 내용을 다시 확인해주세요.',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final bool isEmailVerified = authState.isEmailVerifiedForRegistration;
    final cookieRunTextStyle = TextStyle(fontFamily: Assets.Fonts.cookieRun);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          previous?.status != AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!, style: cookieRunTextStyle)),
        );
      } else if (previous?.status == AuthStatus.loading &&
          next.status == AuthStatus.unauthenticated &&
          next.errorMessage == "회원가입 성공! 로그인해주세요.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!, style: cookieRunTextStyle)),
        );
        ref
            .read(authNotifierProvider.notifier)
            .clearRegistrationSuccessMessage();
        ref.read(authNotifierProvider.notifier).resetEmailVerificationState();
        final String registeredId = _idController.text;
        final String registeredPassword = _passwordController.text;
        ref
            .read(authNotifierProvider.notifier)
            .login(registeredId, registeredPassword);
      } else if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        if (ModalRoute.of(context)?.settings.name == '/register') {
          Navigator.pushNamedAndRemoveUntil(
              context, "/product/list", (route) => false);
        }
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요.';
                        }
                        if (value.length < 4 || value.length > 20) {
                          return '아이디는 4자 이상 20자 이하로 입력해주세요.';
                        }
                        if (value.contains(' ')) return '아이디에 공백을 포함할 수 없습니다.';
                        return null;
                      },
                      readOnly: _isCheckingId,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: '중복확인',
                      isLoading: _isCheckingId,
                      onPressed: _isCheckingId ? null : _checkIdAvailability,
                    ),
                  ),
                ],
              ),
              if (_idCheckMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                  child: Text(
                    _idCheckMessage,
                    style: TextStyle(
                      color: _idCheckMessageColor,
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
                  // 비밀번호 유효성 검사: 영문, 숫자 필수, 특수문자(@$!%*?&) 허용, 4~20자
                  if (!RegExp(
                          r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&,.]{8,20}$')
                      .hasMatch(value)) {
                    return '비밀번호는 8~16자, 영문, 숫자, 특수문자를 모두 포함해야 합니다.';
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
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _onRegisterButtonPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
