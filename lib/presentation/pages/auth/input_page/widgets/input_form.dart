import 'package:flutter/material.dart';

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  bool _autoLogin = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        // 스크롤 가능하도록 ListView 사용
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Markit Place',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            decoration: const InputDecoration(
              labelText: '아이디',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '아이디를 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
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
              const Text('자동 로그인'),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8BFE7), // 시안의 연보라색과 유사하게
              minimumSize: const Size(double.infinity, 50), // 버튼 크기
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 약간 둥근 모서리
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // 로그인 로직 처리
                // 예: Navigator.pushReplacementNamed(context, '/main');
              }
            },
            child: const Text(
              '로그인',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // 회원가입 페이지로 이동
                  Navigator.pushNamed(context, '/register');
                },
                child:
                    const Text('회원가입', style: TextStyle(color: Colors.black54)),
              ),
              const Text('|', style: TextStyle(color: Colors.black54)),
              TextButton(
                onPressed: () {
                  // 아이디 찾기 페이지로 이동 (추후 구현)
                },
                child: const Text('아이디 찾기',
                    style: TextStyle(color: Colors.black54)),
              ),
              const Text('|', style: TextStyle(color: Colors.black54)),
              TextButton(
                onPressed: () {
                  // 비밀번호 찾기 페이지로 이동 (추후 구현)
                },
                child: const Text('비밀번호 찾기',
                    style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
