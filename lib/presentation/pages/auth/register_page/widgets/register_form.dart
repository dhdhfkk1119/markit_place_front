// 사용자 회원가입 입력 폼
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/presentation/widgets/custom_small_action_button.dart';

import '../../../../../_core/constants/size.dart';
import '../../../index_stack_page/mypage/my_page.dart';

// 회원가입 폼 StatefulWidget
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

// RegisterForm 상태 관리 클래스
class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(); // 폼 유효성 검사 글로벌 키

  // 입력 필드 컨트롤러
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  // 입력 필드 포커스 노드
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  final _scrollController = ScrollController(); // 키보드 표시 스크롤 제어

  // 컨트롤러 및 포커스 노드 리스트 (리소스 관리용)
  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  // 이메일 도메인 제안 목록
  final List<String> _suggestedDomains = [
    'gmail.com',
    'naver.com',
    'kakao.com',
    'hanmail.net',
    'daum.net',
    'nate.com'
  ];

  // 위젯 초기화
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

    // 각 포커스 노드 스크롤 리스너 추가
    void addEnsureVisibleListener(FocusNode node) {
      node.addListener(() {
        if (node.hasFocus) {
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
      });
    }

    for (final node in _allFocusNodes) {
      addEnsureVisibleListener(node);
    }
  }

  // 위젯 리소스 해제
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

  // 공통 TextFormField 위젯 생성
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontFamily: "CookieRun"),
        suffixIcon: suffixIcon,
        helperText: helperText,
        helperStyle: const TextStyle(fontFamily: "CookieRun"),
        errorStyle: const TextStyle(fontFamily: "CookieRun"),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // 이메일 도메인 제안 선택 처리
  void _onDomainSuggestionTap(String domain) {
    String currentText = _emailController.text;
    int atSignIndex = currentText.indexOf('@');

    if (atSignIndex != -1) {
      currentText = currentText.substring(0, atSignIndex);
    }
    _emailController.text = '$currentText@$domain';
    _emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: _emailController.text.length),
    );
  }

  // 회원가입 폼 UI 빌드
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(middle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이디 입력 필드 및 중복확인 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        labelStyle: TextStyle(fontFamily: "CookieRun"),
                        helperText: '아이디는 4자 이상 20자 이하로 입력해주세요.',
                        helperStyle: TextStyle(fontFamily: "CookieRun"),
                        errorStyle: TextStyle(fontFamily: "CookieRun"),
                      ),
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
                        left: small, top: small, right: tiny),
                    child: CustomSmallActionButton(
                      text: '중복확인',
                      onPressed: () {
                        // TODO: 아이디 중복 확인 로직
                        if (kDebugMode) {
                          print('아이디 중복 확인: ${_idController.text}');
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: middle),
              // 비밀번호 입력 필드
              _buildTextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                labelText: '비밀번호',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 8 || value.length > 20) {
                    return '비밀번호는 8자 이상 20자 이하이어야 합니다.';
                  }
                  return null;
                },
                helperText: '비밀번호는 8자 이상 20자 이하로 입력해주세요.',
              ),
              const SizedBox(height: middle),
              // 비밀번호 확인 필드
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
              const SizedBox(height: middle),
              // 이메일 인증 섹션 타이틀
              CustomWidget.buildTitle("이메일 인증하기"),
              const SizedBox(height: small),
              // 이메일 입력 필드 및 인증번호 전송 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      labelText: '이메일 주소',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일 주소를 입력해주세요.';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return '유효한 이메일 형식이 아닙니다.';
                        }
                        return null;
                      },
                      helperText: '예: example@markit.com',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: tiny),
                    child: CustomSmallActionButton(
                      text: '인증번호 전송',
                      onPressed: () {
                        // TODO: 인증번호 전송 로직
                        if (kDebugMode) {
                          print('인증번호 전송: ${_emailController.text}');
                        }
                      },
                    ),
                  ),
                ],
              ),
              // 이메일 도메인 제안 버튼
              Padding(
                padding: const EdgeInsets.only(top: tiny),
                child: Wrap(
                  spacing: small,
                  runSpacing: tiny,
                  children: _suggestedDomains.map((domain) {
                    return OutlinedButton(
                      onPressed: () => _onDomainSuggestionTap(domain),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: small, vertical: tiny),
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(tiny),
                        ),
                      ),
                      child: Text(domain,
                          style: const TextStyle(fontFamily: "CookieRun")),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: middle),
              // 인증번호 입력 필드
              _buildTextFormField(
                controller: _verificationCodeController,
                focusNode: _verificationCodeFocusNode,
                labelText: '인증번호',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '인증번호를 입력해주세요.';
                  }
                  return null; // TODO: 인증번호 유효성 검사
                },
                helperText: '이메일로 전송된 인증번호를 입력해주세요.',
              ),
              const SizedBox(height: third),
              // 가입하기 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8BFE7),
                  minimumSize: const Size(double.infinity, half),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(small),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: 회원가입 로직 및 성공/실패 처리
                    final id = _idController.text;
                    final password = _passwordController.text;
                    final email = _emailController.text;
                    final verificationCode = _verificationCodeController.text;
                    if (kDebugMode) {
                      print(
                          '회원가입 시도: ID:$id, Email:$email, Code:$verificationCode');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPage()),
                    );
                  }
                },
                child: const Text(
                  '가입하기',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: middle,
                      fontFamily: "CookieRun"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
