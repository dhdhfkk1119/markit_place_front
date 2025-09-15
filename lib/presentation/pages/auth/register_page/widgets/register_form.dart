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
    bool readOnly = false, // readOnly 파라미터 추가
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
      readOnly: readOnly, // TextFormField에 readOnly 적용
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
        const SnackBar(
            content: Text('유효한 이메일 주소를 입력해주세요.',
                style: TextStyle(fontFamily: "CookieRun"))),
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
        const SnackBar(
            content: Text('인증번호가 발송되었습니다. 이메일을 확인해주세요.',
                style: TextStyle(fontFamily: "CookieRun"))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증번호 발송 실패: ${e.toString()}',
                style: TextStyle(fontFamily: "CookieRun"))),
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
        const SnackBar(
            content: Text('이메일과 인증번호를 모두 입력해주세요.',
                style: TextStyle(fontFamily: "CookieRun"))),
      );
      return;
    }
    // 간단한 인증 코드 유효성 검사 (예: 6자리) - 실제 상세 검증은 서버에서!
    if (code.length != 6) {
      // 예시로 6자리로 가정
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('인증번호 6자리를 입력해주세요.',
                style: TextStyle(fontFamily: "CookieRun"))),
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
          const SnackBar(
              content: Text('이메일 인증이 완료되었습니다.',
                  style: TextStyle(fontFamily: "CookieRun"))),
        );
        // AuthState의 isEmailVerifiedForRegistration이 true로 변경되었으므로,
        // UI는 ref.watch(authNotifierProvider)를 통해 자동으로 업데이트됨.
        // 예를 들어, 인증 코드 입력 필드와 확인 버튼이 비활성화되거나 텍스트가 변경됨.
        _verificationCodeController.clear(); // 인증 성공 시 코드 입력 필드 비움
        FocusScope.of(context).unfocus(); // 키보드 숨김
      } else {
        // 이 경우는 AuthNotifier에서 confirmEmailVerification이 false를 반환할 때 해당 (현재는 Exception throw)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('인증번호가 일치하지 않습니다.', style: TextStyle(fontFamily: "CookieRun"))),
        // );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('인증 실패: ${e.toString()}',
                style: TextStyle(fontFamily: "CookieRun"))),
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
    // isEmailVerifiedForRegistration 상태를 읽음
    final currentAuthState = ref.read(authNotifierProvider);

    // 가입 로딩 상태가 아니고, 개별 버튼 로딩 상태도 아닐 때만 진행
    if (currentAuthState.status == AuthStatus.loading ||
        _isSendingVerificationEmail ||
        _isConfirmingVerificationCode) {
      return;
    }

    // 이메일 인증 여부 확인
    if (!currentAuthState.isEmailVerifiedForRegistration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('이메일 인증을 먼저 완료해주세요.',
                style: TextStyle(fontFamily: "CookieRun"))),
      );
      return;
    }

    if (widget.agreedTermIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('약관 동의 정보가 올바르지 않습니다. 다시 시도해주세요.',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        ),
      );
      return;
    }

    // 폼 유효성 검사
    if (_formKey.currentState!.validate()) {
      final memberToRegister = Member.forRegistration(
        loginId: _idController.text,
        password: _passwordController.text,
        email: _emailController.text,
        agreedTermIds: widget.agreedTermIds,
        isEmailVerified: currentAuthState
            .isEmailVerifiedForRegistration, // AuthState에서 가져온 값 사용
      );
      authNotifier.register(memberToRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    // authState를 watch하여 isEmailVerifiedForRegistration 값의 변화를 감지
    final authState = ref.watch(authNotifierProvider);
    final bool isEmailVerified =
        authState.isEmailVerifiedForRegistration; // 이메일 인증 상태
    const cookieRunTextStyle = TextStyle(fontFamily: Assets.Fonts.cookieRun);
    const cookieRunBlackTextStyle =
        TextStyle(fontFamily: Assets.Fonts.cookieRun, color: Colors.black87);

    // 회원가입 성공 또는 에러 시 SnackBar 표시 리스너
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // 이메일 인증 관련 에러는 여기서 직접 처리하지 않고, 각 버튼 핸들러에서 처리함.
      // 여기서는 주로 회원가입 자체의 성공/실패 메시지만 처리.
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          previous?.status != AuthStatus.error) {
        // 이메일 인증 과정에서 발생한 에러는 개별 핸들러에서 스낵바를 이미 띄웠으므로,
        // 여기서는 회원가입(register) 자체에서 발생한 에러만 표시하도록 조건을 추가할 수 있음.
        // (예: next.errorMessage 가 "회원가입" 관련 메시지일 때만)
        // 지금은 모든 error 상태에 대해 표시.
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
        // 회원가입 성공 시 이메일 인증 상태 초기화 (다음 가입을 위해)
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
              CustomWidget.buildTitle("아이디/비밀번호 입력하기"), // 역슬래시 제거
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
                      readOnly: false, // 명시적으로 false 추가
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
                readOnly: false, // 명시적으로 false 추가
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
                readOnly: false, // 명시적으로 false 추가
              ),
              const SizedBox(height: medium),

              CustomWidget.buildTitle("이메일 인증하기"), // 역슬래시 제거
              const SizedBox(height: small),
              // 이메일 주소 입력 필드
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
                      readOnly: isEmailVerified, // 인증 완료 시 수정 불가
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
                    // "인증번호 전송" 버튼
                    child: CustomButtonMedium(
                      text: '인증번호 전송',
                      isLoading: _isSendingVerificationEmail, // 로딩 상태 반영
                      // 로딩 중이거나, 이미 이메일 인증이 완료되었으면 버튼 비활성화
                      onPressed: _isSendingVerificationEmail || isEmailVerified
                          ? null
                          : _handleSendVerificationEmail,
                    ),
                  ),
                ],
              ),
              // 이메일 도메인 추천 버튼들
              Padding(
                padding: const EdgeInsets.only(top: xSmall),
                child: Wrap(
                  spacing: small,
                  runSpacing: xSmall,
                  children: _suggestedDomains.map((domain) {
                    return OutlinedButton(
                      // 이메일 인증 완료 시 도메인 추천 버튼 비활성화 (선택적)
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
              // 인증번호 입력 필드
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
                      readOnly: isEmailVerified, // 인증 완료 시 수정 불가
                      validator: (value) {
                        // 인증이 아직 안됐는데 코드가 비어있으면 에러
                        if (!isEmailVerified &&
                            (value == null || value.isEmpty))
                          return '인증번호를 입력해주세요.';
                        // TODO: 인증번호 형식 (예: 6자리 숫자) 검사 추가 가능
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    // "인증확인" 버튼
                    child: CustomButtonMedium(
                      text: isEmailVerified ? '인증완료' : '인증확인', // 상태에 따라 텍스트 변경
                      isLoading: _isConfirmingVerificationCode, // 로딩 상태 반영
                      // 로딩 중이거나, 이미 이메일 인증이 완료되었으면 버튼 비활성화
                      onPressed:
                          _isConfirmingVerificationCode || isEmailVerified
                              ? null
                              : _handleConfirmVerificationCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: xLarge),
              // "가입하기" 버튼
              CustomButtonLarge(
                // 로딩 상태에 따른 버튼 텍스트 변경 (회원가입 로딩, 이메일 인증 로딩 구분)
                text: authState.status == AuthStatus.loading &&
                        !(_isSendingVerificationEmail ||
                            _isConfirmingVerificationCode)
                    ? '가입 처리 중...'
                    : (_isSendingVerificationEmail
                        ? '인증번호 전송중...'
                        : (_isConfirmingVerificationCode
                            ? '인증 확인중...'
                            : '가입하기')),
                // 여러 로딩 상태 또는 약관 미동의 시 버튼 비활성화
                onPressed: authState.status == AuthStatus.loading ||
                        widget.agreedTermIds.isEmpty ||
                        _isSendingVerificationEmail ||
                        _isConfirmingVerificationCode
                    ? null
                    : _onRegisterButtonPressed, // 내부에서 isEmailVerified 최종 체크
              ),
              const SizedBox(height: large),
            ],
          ),
        ),
      ),
    );
  }
}
