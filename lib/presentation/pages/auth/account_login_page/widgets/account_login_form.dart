import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart'; // 상수 파일 임포트

// 계정 로그인을 위한 입력 폼 위젯 (StatefulWidget)
class AccountLoginForm extends StatefulWidget {
  const AccountLoginForm({super.key});

  @override
  State<AccountLoginForm> createState() => _AccountLoginFormState();
}

class _AccountLoginFormState extends State<AccountLoginForm> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 관리하고 유효성 검사를 위한 키
  bool _autoLogin = false; // '자동 로그인' 체크박스 상태

  // TODO: 아이디, 비밀번호 컨트롤러 추가 (TextEditingController)

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        // 폼 내용이 길어질 경우 스크롤 가능하도록 ListView 사용
        children: [
          const SizedBox(height: medium),
          // 앱/서비스 타이틀
          const Center(
            child: Text(
              'Markit Place', // TODO: 앱 이름 상수화 또는 테마에서 관리 고려
              style: TextStyle(
                  fontSize: large,
                  fontWeight: FontWeight.bold,
                  fontFamily: "CookieRun"), // TODO: 폰트 테마 적용 고려
            ),
          ),
          const SizedBox(height: xLarge),

          // 아이디 입력 필드
          TextFormField(
            // controller: _idController, // TODO: 컨트롤러 연결
            decoration: const InputDecoration(
              labelText: '아이디',
              border: OutlineInputBorder(), // 모든 면에 테두리 적용
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '아이디를 입력해주세요.'; // 유효성 검사 메시지
              }
              // TODO: 아이디 형식 유효성 검사 추가 (예: 길이, 특수문자 등)
              return null; // 유효한 경우 null 반환
            },
          ),
          const SizedBox(height: medium),

          // 비밀번호 입력 필드
          TextFormField(
            // controller: _passwordController, // TODO: 컨트롤러 연결
            decoration: const InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(),
            ),
            obscureText: true, // 입력 내용 가리기
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요.';
              }
              // TODO: 비밀번호 정책 유효성 검사 추가
              return null;
            },
          ),
          const SizedBox(height: small),

          // 자동 로그인 옵션
          Row(
            children: [
              Checkbox(
                value: _autoLogin,
                onChanged: (bool? value) {
                  setState(() {
                    // 체크박스 상태 변경 시 UI 업데이트
                    _autoLogin = value ?? false;
                  });
                },
                // TODO: 테마의 activeColor 고려
              ),
              const Text('자동 로그인', style: TextStyle(fontFamily: "CookieRun")),
            ],
          ),
          const SizedBox(height: medium),

          // 로그인 버튼
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8BFE7), // TODO: 테마 색상 사용
              minimumSize: const Size(double.infinity, xxLarge), // 버튼 최소 크기 지정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(small),
              ),
            ),
            onPressed: () {
              // 폼 유효성 검사 실행
              if (_formKey.currentState!.validate()) {
                // 유효성 검사 통과 시 로그인 로직 처리
                // TODO: 실제 로그인 로직 구현 (예: API 호출)
                print('로그인 시도: ID 입력값, PW 입력값');
                Navigator.pushNamed(context, "product/list");
              }
            },
            child: const Text(
              '로그인',
              style: TextStyle(
                  fontSize: medium,
                  color: Colors.white, // TODO: 테마 색상
                  fontFamily: "CookieRun"), // TODO: 폰트 테마
            ),
          ),
          const SizedBox(height: medium),

          // 추가 액션 링크 (회원가입, 아이디/비밀번호 찾기)
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              TextButton(
                onPressed: () {
                  // 회원가입 페이지로 이동 (명명된 라우트 사용)
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
                  // TODO: 아이디 찾기 페이지로 이동 로직 구현
                  print('아이디 찾기 클릭');
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
                  // TODO: 비밀번호 찾기 페이지로 이동 로직 구현
                  print('비밀번호 찾기 클릭');
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
