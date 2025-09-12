import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/members/models/member.dart';
import 'package:markit_place_front/domain/members/providers/member_auth_provider.dart';
// import 'package:markit_place_front/presentation/pages/auth/terms_page/terms_page.dart'; // 새로운 흐름에서는 직접 호출 안 함
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_medium.dart';

class RegisterForm extends ConsumerStatefulWidget {
  final List<int> agreedTermIds; // 생성자 파라미터로 약관 ID 목록을 받음

  const RegisterForm({super.key, required this.agreedTermIds});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();

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

  // 이제 생성자를 통해 agreedTermIds를 받으므로, 이 상태 변수들은 직접 사용되지 않거나 다른 방식으로 활용 가능
  // List<int>? _agreedTermIdsFromTermsPage;
  // bool _termsAgreed = false;

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
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller.dispose();
    }
    for (final node in _allFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureVisible(FocusNode node) {
    if (node.hasFocus && mounted && node.context != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && node.context != null) {
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
  }) {
    const defaultLabelStyle =
        TextStyle(fontFamily: "CookieRun", color: Colors.black87);
    final defaultHelperStyle =
        TextStyle(fontFamily: "CookieRun", color: Colors.grey.shade700);
    const defaultErrorStyle = TextStyle(
        fontFamily: "CookieRun",
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

  void _onRegisterButtonPressed() {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final currentAuthState = ref.read(authNotifierProvider);

    if (currentAuthState.status == AuthStatus.loading) {
      return;
    }

    // TermsPage에서 필수 약관 동의는 이미 검증되었으므로,
    // 여기서는 widget.agreedTermIds가 비어있는지만 간단히 확인하거나, 특정 개수 이상인지 확인할 수 있음.
    if (widget.agreedTermIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '약관 동의 정보가 올바르지 않습니다. 다시 시도해주세요.',
            style: TextStyle(fontFamily: "CookieRun"),
          ),
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
        // 생성자를 통해 받은 ID 목록 사용
        isEmailVerified: false,
      );
      authNotifier.register(memberToRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    const cookieRunTextStyle = TextStyle(fontFamily: "CookieRun");
    const cookieRunBlackTextStyle =
        TextStyle(fontFamily: "CookieRun", color: Colors.black87);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomButtonMedium(
                      text: '중복확인',
                      onPressed: () {
                        /* TODO: 아이디 중복확인 API 연동 */
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return '이메일 주소를 입력해주세요.';
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
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
                      onPressed: () {
                        /* TODO: 이메일 인증번호 전송 API 연동 */
                      },
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
                      onPressed: () => _onDomainSuggestionTap(domain),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: small, vertical: xSmall),
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 1.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(xSmall)),
                      ),
                      child: Text(domain, style: cookieRunBlackTextStyle),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: medium),
              _buildTextFormField(
                controller: _verificationCodeController,
                focusNode: _verificationCodeFocusNode,
                labelText: '인증번호',
                keyboardType: TextInputType.number,
                helperText: '이메일로 전송된 인증번호를 입력해주세요.',
                validator: (value) {
                  if (value == null || value.isEmpty) return '인증번호를 입력해주세요.';
                  return null;
                },
              ),
              const SizedBox(height: medium),

              // 약관 동의 UI는 새로운 흐름에 따라 제거 또는 수정됨
              // 예를 들어, 동의 완료 상태만 간단히 표시할 수 있음:
              CustomWidget.buildTitle("약관 동의 정보"),
              const SizedBox(height: small),
              if (widget.agreedTermIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(small),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(xSmall),
                    color: Colors.green.shade50,
                  ),
                  child: Text(
                    "약관 동의 완료 (동의 항목: ${widget.agreedTermIds.length}개)",
                    style: cookieRunTextStyle.copyWith(
                        color: Colors.green.shade800),
                  ),
                ),
              if (widget.agreedTermIds.isEmpty) // 혹시라도 ID가 안 넘어온 경우
                Container(
                  padding: const EdgeInsets.all(small),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(xSmall),
                    color: Colors.red.shade50,
                  ),
                  child: Text(
                    "약관 동의 정보가 수신되지 않았습니다. 회원가입을 다시 진행해주세요.",
                    style:
                        cookieRunTextStyle.copyWith(color: Colors.red.shade800),
                  ),
                ),
              const SizedBox(height: xLarge),

              CustomButtonLarge(
                text: authState.status == AuthStatus.loading
                    ? '가입 처리 중...'
                    : '가입하기',
                // agreedTermIds가 비어있으면 가입 버튼 비활성화 (선택적)
                onPressed: authState.status == AuthStatus.loading ||
                        widget.agreedTermIds.isEmpty
                    ? null
                    : _onRegisterButtonPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
