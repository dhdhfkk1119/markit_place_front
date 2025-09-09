import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart'; // 간격 상수 사용을 위해 import
// theme.dart에서 kAppButtonSolidColor를 가져오기 위해 import 필요시 추가
// 예: import 'package:markit_place_front/_core/constants/theme.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  final List<String> _suggestedDomains = [
    'gmail.com',
    'naver.com',
    'kakao.com',
    'hanmail.net'
  ];

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        helperText: helperText,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _onDomainSuggestionTap(String domain) {
    String currentText = _emailController.text;
    int atSignIndex = currentText.indexOf('@');

    if (atSignIndex != -1) {
      // @가 이미 있다면, @ 앞부분만 유지하고 새 도메인 추가
      currentText = currentText.substring(0, atSignIndex);
    }
    // @가 없거나, @ 앞부분만 남긴 상태에서 새 도메인 결합
    _emailController.text = '$currentText@$domain';
    // 커서를 텍스트 끝으로 이동
    _emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: _emailController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이디 입력 필드
          TextFormField(
            controller: _idController,
            decoration: InputDecoration(
              labelText: '아이디',
              helperText: '아이디는 4자 이상 20자 이하로 입력해주세요.',
              suffixIcon: Padding(
                padding: const EdgeInsets.only(left: tenGap),
                child: ElevatedButton(
                  onPressed: () {
                    print('아이디 중복 확인: ${_idController.text}');
                  },
                  child: const Text('중복확인'),
                ),
              ),
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
          const SizedBox(height: twenGap),

          // 비밀번호 입력 필드
          _buildTextFormField(
            controller: _passwordController,
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
          const SizedBox(height: twenGap),

          // 비밀번호 확인 입력 필드
          _buildTextFormField(
            controller: _passwordConfirmController,
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
            helperText: '비밀번호는 8자 이상 20자 이하로 입력해주세요.',
          ),
          const SizedBox(height: twenGap),

          // 이메일 인증 섹션
          const Text('이메일 인증하기', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: tenGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _emailController,
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
                padding: const EdgeInsets.only(left: tenGap, top: tenGap),
                child: ElevatedButton(
                  onPressed: () {
                    print('인증번호 전송: ${_emailController.text}');
                  },
                  child: const Text('인증번호 전송'),
                ),
              ),
            ],
          ),
          // 도메인 제안 버튼 추가
          Padding(
            padding: const EdgeInsets.only(top: fiveGap), // 이메일 필드와 간격
            child: Wrap(
              spacing: 8.0, // 버튼 간 가로 간격
              runSpacing: 4.0, // 줄 바꿈 시 세로 간격
              children: _suggestedDomains.map((domain) {
                return OutlinedButton(
                  onPressed: () => _onDomainSuggestionTap(domain),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    // textStyle: TextStyle(fontSize: 12), // 필요시 폰트 크기 조절
                    // minimumSize: Size(0, 30), // 버튼 최소 크기 조절
                  ),
                  child: Text(domain),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: twenGap), // 도메인 버튼과 다음 필드 사이 간격

          // 인증번호 입력 필드
          _buildTextFormField(
            controller: _verificationCodeController,
            labelText: '인증번호',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '인증번호를 입력해주세요.';
              }
              return null;
            },
            helperText: '이메일로 전송된 인증번호를 입력해주세요.',
          ),
          const SizedBox(height: thiGap),

          // 가입하기 버튼
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final id = _idController.text;
                final password = _passwordController.text;
                final email = _emailController.text;
                final verificationCode = _verificationCodeController.text;
                print('회원가입 시도: ID:$id, Email:$email, Code:$verificationCode');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('회원가입 요청 중...'),
                  ),
                );
              }
            },
            child: const Text('가입하기'),
          ),
        ],
      ),
    );
  }
}
