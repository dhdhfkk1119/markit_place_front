import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'; // kReleaseMode 등을 사용하지 않으면 필요 없음
import 'package:markit_place_front/_core/constants/custom_widget.dart'; // 사용자 정의 위젯 (buildTitle)
import 'package:markit_place_front/_core/constants/size.dart'; // 상수 파일 임포트
import 'package:markit_place_front/presentation/widgets/custom_small_action_button.dart'; // 작은 액션 버튼
// import '../../../index_stack_page/mypage/my_page.dart'; // 현재 MyPage 직접 이동 로직은 주석 처리 또는 제거 고려

// 회원가입에 필요한 다양한 입력 필드와 유효성 검사, 관련 로직을 포함하는 StatefulWidget
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(); // 폼 전체의 상태 및 유효성 검사를 위한 키

  // 각 입력 필드의 텍스트를 관리하는 컨트롤러
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  // 각 입력 필드의 포커스 상태를 관리하는 노드 (키보드 나타날 때 스크롤 조정 등에 사용)
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  // 스크롤 제어를 위한 컨트롤러 (주로 키보드 표시 시 가려지는 필드를 보이게 하기 위함)
  final _scrollController = ScrollController();

  // initState에서 초기화될 컨트롤러 및 포커스 노드 목록 (dispose에서 일괄 해제 목적)
  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  // 이메일 입력 시 도메인 자동 완성을 위한 제안 목록
  final List<String> _suggestedDomains = [
    'gmail.com',
    'naver.com',
    'kakao.com',
    'hanmail.net',
    'daum.net',
    'nate.com', // TODO: 더 많은 도메인 또는 사용자 직접 입력 옵션 고려
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

    // 각 포커스 노드에 리스너를 추가하여, 해당 필드에 포커스가 갔을 때 화면에 보이도록 스크롤 조정
    for (final node in _allFocusNodes) {
      node.addListener(() => _ensureVisible(node));
    }
  }

  // 위젯이 제거될 때 모든 컨트롤러와 포커스 노드의 리소스를 해제
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

  // 특정 포커스 노드가 활성화되었을 때 해당 위젯이 화면에 보이도록 스크롤하는 함수
  void _ensureVisible(FocusNode node) {
    if (node.hasFocus && mounted && node.context != null) {
      // 약간의 지연 후 스크롤 실행 (키보드가 완전히 올라온 후 정확한 위치 계산 위함)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && node.context != null) {
          // Future 내에서도 mounted 및 context 확인
          Scrollable.ensureVisible(
            node.context!,
            duration: const Duration(milliseconds: 250), // 스크롤 애니메이션 지속 시간
            curve: Curves.easeInOut, // 스크롤 애니메이션 곡선
            alignment: 0.1, // 화면 상단에서 약간 아래(10%)에 위치하도록 정렬
          );
        }
      });
    }
  }

  // 반복적인 TextFormField 생성을 위한 헬퍼 함수
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? helperText,
    TextStyle? labelStyle,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
    Widget? suffixIcon, // suffixIcon 파라미터 추가
  }) {
    final defaultTextStyle =
        const TextStyle(fontFamily: "CookieRun"); // TODO: 테마 폰트
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle ?? defaultTextStyle,
        helperText: helperText,
        helperStyle: helperStyle ?? defaultTextStyle,
        errorStyle: errorStyle ?? defaultTextStyle,
        suffixIcon: suffixIcon, // suffixIcon 적용
        // TODO: border, focusedBorder 등 테마 적용 고려
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // 이메일 도메인 제안 목록의 버튼 클릭 시 이메일 필드를 업데이트하는 함수
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

  // 회원가입 버튼 클릭 시 실행되는 함수
  void _onRegisterButtonPressed() {
    if (_formKey.currentState!.validate()) {
      // 폼 유효성 검사 통과 시
      print("가입하기 클릭");
      Navigator.pushNamed(context, "product/list"); // 임시: 상품 목록으로 이동

      // 주석처리된 이전 로직:
      // final id = _idController.text;
      // final password = _passwordController.text;
      // final email = _emailController.text;
      // final verificationCode = _verificationCodeController.text;
      // print(
      //     '회원가입 시도: ID:$id, Email:$email, Code:$verificationCode (Password는 보안상 로그 제외)');
      // // TODO: 실제 회원가입 API 호출 및 결과 처리ㅁㄴ
      // // 성공 시 예: Navigator.pushReplacementNamed(context, '/login');
      // // 실패 시 예: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 실패: 서버 오류')));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('회원가입 요청됨 (서버 연동 필요)')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle =
        const TextStyle(fontFamily: "CookieRun"); // TODO: 테마 폰트

    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이디 입력 필드 및 중복확인 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      labelText: '아이디',
                      labelStyle: defaultTextStyle,
                      helperText: '아이디는 4자 이상 20자 이하로 입력해주세요.',
                      helperStyle: defaultTextStyle,
                      errorStyle: defaultTextStyle,
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
                        // TODO: 아이디 형식 정규식 검사 (영문, 숫자 조합 등)
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomSmallActionButton(
                      text: '중복확인',
                      onPressed: () {
                        if (_idController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('아이디를 먼저 입력해주세요.')),
                          );
                          return;
                        }
                        // TODO: 실제 아이디 중복 확인 API 호출
                        print('아이디 중복 확인 요청: ${_idController.text}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${_idController.text} 중복확인 (서버 연동 필요)')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: medium),

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
                  // TODO: 비밀번호 강도 검사 (대소문자, 숫자, 특수문자 조합 등)
                  return null;
                },
                helperText: '비밀번호는 8자 이상 20자 이하로 입력해주세요.',
                labelStyle: defaultTextStyle,
                helperStyle: defaultTextStyle,
                errorStyle: defaultTextStyle,
              ),
              const SizedBox(height: medium),

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
                labelStyle: defaultTextStyle,
                errorStyle: defaultTextStyle,
              ),
              const SizedBox(height: medium),

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
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!emailRegex.hasMatch(value)) {
                          return '유효한 이메일 형식이 아닙니다.';
                        }
                        return null;
                      },
                      helperText: '예: example@markit.com',
                      labelStyle: defaultTextStyle,
                      helperStyle: defaultTextStyle,
                      errorStyle: defaultTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: small, top: small, right: xSmall),
                    child: CustomSmallActionButton(
                      text: '인증번호 전송',
                      onPressed: () {
                        final email = _emailController.text;
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이메일 주소를 먼저 입력해주세요.')),
                          );
                          return;
                        }
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!emailRegex.hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('유효한 이메일 형식이 아닙니다.')),
                          );
                          return;
                        }
                        // TODO: 실제 인증번호 전송 API 호출
                        print('인증번호 전송 요청: $email');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('$email 로 인증번호 전송 (서버 연동 필요)')),
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
                        side: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0), // TODO: 테마 색상
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(xSmall),
                        ),
                      ),
                      child: Text(domain, style: defaultTextStyle),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '인증번호를 입력해주세요.';
                  }
                  // TODO: 실제 인증번호 유효성 검사 (API 호출 또는 비교)
                  return null;
                },
                helperText: '이메일로 전송된 인증번호를 입력해주세요.',
                labelStyle: defaultTextStyle,
                helperStyle: defaultTextStyle,
                errorStyle: defaultTextStyle,
              ),
              const SizedBox(height: xLarge),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFC8BFE7), // TODO: 테마 색상 (primary?)
                  minimumSize: const Size(double.infinity, xxLarge),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(small),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white, fontFamily: 'CookieRun'), // 테마 + 커스텀
                ),
                onPressed:
                    _onRegisterButtonPressed, // _onRegisterButtonPressed 함수를 직접 연결
                child: const Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
