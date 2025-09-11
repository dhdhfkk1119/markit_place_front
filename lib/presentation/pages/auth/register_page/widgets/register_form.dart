import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_medium.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';

// 회원가입 폼 위젯
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(); // 폼 상태 관리를 위한 키

  // 컨트롤러
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  // 포커스 노드
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController(); // 스크롤 컨트롤러

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

  // 포커스된 위젯이 보이도록 스크롤 조정
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

  // TextFormField 생성 헬퍼
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? helperText,
    Widget? suffixIcon,
    TextStyle? labelStyle,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
  }) {
    // 기본 스타일 정의 (검정색 계열 및 CookieRun 폰트)
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
        labelStyle: labelStyle ?? defaultLabelStyle,
        helperText: helperText,
        helperStyle: helperStyle ?? defaultHelperStyle,
        errorStyle: errorStyle ?? defaultErrorStyle,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // 이메일 도메인 선택 시 필드 업데이트
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

  // "가입하기" 버튼 클릭 로직
  void _onRegisterButtonPressed() {
    if (_formKey.currentState!.validate()) {
      print("가입하기 클릭");
      Navigator.pushNamed(context, "product/list");
      // TODO: 실제 회원가입 API 호출 및 결과 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    // SnackBar 및 OutlinedButton에 사용할 기본 CookieRun 폰트 스타일
    const cookieRunTextStyle = TextStyle(fontFamily: "CookieRun");
    const cookieRunBlackTextStyle =
        TextStyle(fontFamily: "CookieRun", color: Colors.black87);

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
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요.';
                        }
                        if (value.length < 4 || value.length > 20) {
                          return '아이디는 4자 이상 20자 이하로 입력해주세요.';
                        }
                        if (value.contains(' ')) {
                          return '아이디에 공백을 포함할 수 없습니다.';
                        }
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
                        if (_idController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('아이디를 먼저 입력해주세요.',
                                    style:
                                        cookieRunTextStyle)), // CookieRun 폰트 적용
                          );
                          return;
                        }
                        print('아이디 중복 확인 요청: ${_idController.text}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${_idController.text} 중복확인 (서버 연동 필요)',
                                  style:
                                      cookieRunTextStyle)), // CookieRun 폰트 적용
                        );
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
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 8 || value.length > 20) {
                    return '비밀번호는 8자 이상 20자 이하이어야 합니다.';
                  }
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
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 한번 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
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
                        if (value == null || value.isEmpty) {
                          return '이메일 주소를 입력해주세요.';
                        }
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!emailRegex.hasMatch(value)) {
                          return '유효한 이메일 형식이 아닙니다.';
                        }
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
                        final email = _emailController.text;
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('이메일 주소를 먼저 입력해주세요.',
                                    style:
                                        cookieRunTextStyle)), // CookieRun 폰트 적용
                          );
                          return;
                        }
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!emailRegex.hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('유효한 이메일 형식이 아닙니다.',
                                    style:
                                        cookieRunTextStyle)), // CookieRun 폰트 적용
                          );
                          return;
                        }
                        print('인증번호 전송 요청: $email');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('$email 로 인증번호 전송 (서버 연동 필요)',
                                  style:
                                      cookieRunTextStyle)), // CookieRun 폰트 적용
                        );
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
                      child: Text(domain,
                          style:
                              cookieRunBlackTextStyle), // CookieRun 폰트 및 검정 계열 색상 적용
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
                  if (value == null || value.isEmpty) {
                    return '인증번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: xLarge),
              CustomButtonLarge(
                text: '가입하기',
                onPressed: _onRegisterButtonPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
