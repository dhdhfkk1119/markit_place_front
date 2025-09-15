import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';

import '../../../../../_core/constants/assets.dart'; // import 문 추가/확인

// 비밀번호 초기화 폼 위젯
class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  // TODO: 실제 사용을 위해 FormKey, TextEditingController 추가 필요
  // final _formKey = GlobalKey<FormState>();
  // final _emailOrIdController = TextEditingController();
  bool _isLoading = false;

  // @override
  // void dispose() {
  //   _emailOrIdController.dispose();
  //   super.dispose();
  // }

  Future<void> _handleResetPassword() async {
    // if (_formKey.currentState!.validate()) { // TODO: 유효성 검사 활성화
    setState(() {
      _isLoading = true;
    });

    print('비밀번호 재설정 버튼 클릭됨 (입력값: TODO)');
    await Future.delayed(const Duration(seconds: 1)); // 임시 비동기 작업

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // 예시: SnackBar 메시지 (CookieRun 폰트 적용)
    // bool success = true; // API 호출 결과에 따라 설정
    // if (success) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('비밀번호 재설정 메일이 발송되었습니다.', style: TextStyle(fontFamily: Fonts.cookieRun))),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('메일 발송에 실패했습니다.', style: TextStyle(color: Theme.of(context).colorScheme.error, fontFamily: Fonts.cookieRun))),
    //   );
    // }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cookieRunPrimaryColorTextStyle = TextStyle(
        fontFamily: Fonts.cookieRun, color: theme.colorScheme.primary);

    return Padding(
      padding: const EdgeInsets.all(medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: medium),
          Text(
            '가입 시 사용한 아이디 또는 이메일을 입력해주세요.',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontFamily: Fonts.cookieRun),
          ),
          const SizedBox(height: medium),
          TextFormField(
            // controller: _emailOrIdController, // TODO: 컨트롤러 연결
            decoration: const InputDecoration(
              hintText: '아이디 또는 이메일 입력',
            ),
            style: cookieRunPrimaryColorTextStyle, // 입력 텍스트 스타일
            // validator: (value) { // TODO: 유효성 검사 추가
            //   if (value == null || value.isEmpty) {
            //     return '아이디 또는 이메일을 입력해주세요.';
            //   }
            //   return null;
            // },
          ),
          const SizedBox(height: xLarge),
          CustomButtonLarge(
            text: '비밀번호 재설정 메일 발송',
            isLoading: _isLoading, // isLoading prop 사용
            onPressed: () {
              _handleResetPassword();
            }, // onPressed 간결화 (내부에서 isLoading 처리)
          ),
        ],
      ),
    );
  }
}
