import 'package:flutter/material.dart';
import '../../_core/constants/size.dart';

import '../../_core/constants/assets.dart';

/// 핵심 기능이 들어있는 최종 제출버튼이다.
// 가입, 로그인
class CustomButtonLarge extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButtonLarge({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme 변수는 계속 사용될 수 있으므로 유지합니다.

    final ButtonStyle submitButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurpleAccent, // kAppButtonSolidColor 값으로 변경
      minimumSize: const Size(double.infinity, xxLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small),
      ),
    );

    final TextStyle submitButtonTextStyle =
        theme.textTheme.labelLarge!.copyWith(
      fontFamily: Assets.Fonts.cookieRun,
      color: Colors.white, // 폰트 색상: 흰색
      fontSize: medium, // 폰트 크기: medium (16.0)
    );

    return ElevatedButton(
      style: submitButtonStyle,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 24, // 로딩 인디케이터 크기는 유지
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // 로딩 인디케이터 흰색 유지
              ),
            )
          : Text(
              text,
              style: submitButtonTextStyle,
            ),
    );
  }
}
