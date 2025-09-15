import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/_core/constants/theme.dart'; // kAppSecondaryColor 사용
import 'package:markit_place_front/_core/constants/theme.dart';

import '../../_core/constants/assets.dart'; // kAppSecondaryColor를 사용

/// ## CustomButtonMedium (중간 크기 버튼)
///
/// 보조 기능 수행을 위한 중간 크기의 버튼 위젯입니다.
/// 주로 API 호출과 같은 비동기 작업을 동반하는 액션에 사용됩니다. (예: 중복확인, 이메일 인증번호 전송/확인 등)
///
/// ### 주요 기능:
/// - 정해진 스타일(배경색, 텍스트 스타일 등)을 가집니다.
/// - `isLoading` 파라미터를 통해 버튼 내에 로딩 인디케이터를 표시할 수 있습니다.
///
/// ### 사용 시 주의사항:
/// - `onPressed` 콜백: 비동기 작업 완료 후 버튼 상태를 적절히 관리해야 합니다.
/// - `isLoading`: `true`로 설정되면 `onPressed` 콜백은 무시되고 버튼 내에 `CircularProgressIndicator`가 표시됩니다.
///   이때 버튼의 텍스트는 사라집니다. 로딩 상태 관리는 이 버튼을 사용하는 상위 위젯의 책임입니다.
/// - `onPressed`가 `null`이거나 `isLoading`이 `true`이면 버튼은 비활성화 상태가 됩니다.

class CustomButtonMedium extends StatelessWidget {
  final String text; // 버튼에 표시될 텍스트
  final VoidCallback? onPressed; // 버튼 클릭 시 실행될 콜백 함수 (null 가능)
  final bool isLoading; // 로딩 상태 여부 (true이면 로딩 인디케이터 표시)

  const CustomButtonMedium({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false, // 기본값은 false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: kAppSecondaryColor, // 배경색: 테마 상수 사용
      foregroundColor: Colors.black, // 글자/아이콘 기본색: 검정색
      minimumSize: const Size(0, xLarge), // 버튼의 최소 높이
      padding: const EdgeInsets.symmetric(
          horizontal: medium, vertical: small), // 내부 패딩
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small), // 테두리 둥글기
      ),
      textStyle: const TextStyle(
        // 버튼 텍스트 스타일
        fontFamily: Assets.Fonts.cookieRun,
        fontSize: medium,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 탭 영역을 버튼 크기에 맞춤
    );

    return ElevatedButton(
      style: buttonStyle,
      // isLoading이 true이거나 onPressed가 null이면 버튼 비활성화 (null 전달)
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              // 로딩 중일 때 표시할 인디케이터
              height: medium, // 인디케이터 크기 (텍스트 높이와 유사하게)
              width: medium, // 인디케이터 크기
              child: const CircularProgressIndicator(
                strokeWidth: 2.0, // 인디케이터 선 두께
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.black), // 인디케이터 색상
              ),
            )
          : Text(text), // 로딩 중이 아닐 때 표시할 텍스트
    );
  }
}
