import 'package:flutter/material.dart';

// 계정 로그인 폼을 정의하는 StatefulWidget.
class AccounLoginForm extends StatefulWidget {
  const AccounLoginForm({super.key});

  @override
  State<AccounLoginForm> createState() => _AccounLoginFormState();
}

// AccounLoginForm 위젯의 상태를 관리하는 클래스.
class _AccounLoginFormState extends State<AccounLoginForm> {
  bool _autoLogin = false; // 자동 로그인 상태 관리 변수
  final _formKey = GlobalKey<FormState>(); // 폼 상태 관리를 위한 글로벌 키

  // 계정 로그인 폼 UI 빌드.
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Markit Place',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "CookieRun"),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            decoration: const InputDecoration(
              labelText: '아이디',
              // labelStyle은 theme에서 CookieRun 상속
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
              // labelStyle은 theme에서 CookieRun 상속
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
              const Text('자동 로그인', style: TextStyle(fontFamily: "CookieRun")),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8BFE7),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              // textStyle은 theme에서 CookieRun 상속되지만, child Text에서 명시적으로 지정 가능
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: 로그인 로직 처리
              }
            },
            child: const Text(
              '로그인',
              style: TextStyle(
                  fontSize: 16, color: Colors.white, fontFamily: "CookieRun"),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('회원가입',
                    style: TextStyle(
                        color: Colors.black54, fontFamily: "CookieRun")),
              ),
              const Text('|',
                  style: TextStyle(
                      color: Colors.black54, fontFamily: "CookieRun")),
              TextButton(
                onPressed: () {
                  // TODO: 아이디 찾기 페이지로 이동
                },
                child: const Text('아이디 찾기',
                    style: TextStyle(
                        color: Colors.black54, fontFamily: "CookieRun")),
              ),
              const Text('|',
                  style: TextStyle(
                      color: Colors.black54, fontFamily: "CookieRun")),
              TextButton(
                onPressed: () {
                  // TODO: 비밀번호 찾기 페이지로 이동
                },
                child: const Text('비밀번호 찾기',
                    style: TextStyle(
                        color: Colors.black54, fontFamily: "CookieRun")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
