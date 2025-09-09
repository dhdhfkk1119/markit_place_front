import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

/// [CustomAuthTextFormField]
///
/// ## 목적
/// 인증(회원가입, 로그인 등) 관련 폼에서 사용되는 텍스트 입력 필드를 일관된 스타일로 제공하기 위함입니다.
/// 일반 TextFormField 위에 제목(title)을 표시하고, 에러 메시지(errorText) 및 입력값 숨김(obscureText) 기능을 기본적으로 지원합니다.
/// 테두리 스타일(기본, 포커스 시, 에러 시)이 독립적으로 정의되어 있어, 앱 전체 테마의 InputDecorationTheme과 다르게
/// 인증 폼만의 특화된 디자인을 적용할 수 있습니다.
///
/// ## 주요 사용처
/// - AccountLoginForm (예: 아이디/이메일 입력 필드, 비밀번호 입력 필드)
/// - RegisterForm (예: 사용자 이름, 비밀번호, 비밀번호 확인, 이메일 입력 필드 등 - 만약 현재 RegisterForm의 스타일과 부합한다면)
/// - PasswordFindForm (가칭, 비밀번호 찾기/재설정 폼이 실제 구현될 경우)

// 인증 폼 전용 커스텀 TextFormField 위젯
class CustomAuthTextFormField extends StatelessWidget {
  final String title; // 필드 상단에 표시될 제목
  final String errorText; // 유효성 검사 실패 시 표시될 에러 메시지
  final Function(String)? onChanged; // 입력값 변경 시 호출될 콜백 함수
  final bool obscureText; // 입력값 숨김 처리 여부

  // 생성자: 필수값 title, 선택값 errorText, onChanged, obscureText
  CustomAuthTextFormField({
    required this.title,
    this.errorText = "",
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    // 테두리 색상 정의 (앱 테마와 독립적일 수 있음)
    final Color defaultBorderColor = Colors.grey.shade600; // 일반 상태 테두리 색
    final Color focusedBorderColor =
        Theme.of(context).primaryColor; // 포커스 시 테두리 색
    final Color errorBorderColor = Colors.red; // 에러 시 테두리 색

    // 제목과 TextFormField를 Column으로 배치
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title), // 필드 제목 표시
        const SizedBox(height: fiveGap), // 제목과 필드 사이 간격
        TextFormField(
          onChanged: onChanged, // 입력 변경 콜백 연결
          obscureText: obscureText, // 입력값 숨김 처리
          decoration: InputDecoration(
            hintText: "Enter $title", // 힌트 텍스트 설정
            errorText: errorText.isEmpty ? null : errorText, // 에러 메시지 표시
            // 테두리 스타일 정의
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: defaultBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: errorBorderColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: errorBorderColor, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
