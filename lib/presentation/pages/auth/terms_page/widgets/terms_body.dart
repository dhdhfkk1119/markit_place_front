import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/pages/auth/terms_page/widgets/terms_form.dart';

// 약관 동의 페이지의 본문 레이아웃을 담당하는 위젯
class TermsBody extends StatelessWidget {
  const TermsBody({super.key});

  @override
  Widget build(BuildContext context) {
    // 페이지 전체에 일관된 여백을 적용
    return Container(
      // 최상위 위젯을 Container로 감싸고 색상 적용
      color: const Color(0xFFFAF6F2),
      child: Padding(
        padding: const EdgeInsets.all(medium),
        child: Column(
          // 자식 위젯들을 세로로 정렬
          children: [
            Expanded(
              // 남은 공간을 모두 차지하도록 확장
              child: SingleChildScrollView(
                // 내용이 길어질 경우 스크롤 가능하도록
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // 자식 위젯들의 가로 폭을 최대로 확장
                  children: [
                    const SizedBox(height: xLarge),
                    // TODO: 약관 동의 페이지를 나타내는 대표 이미지 또는 아이콘으로 교체 필요
                    Icon(
                      Icons.savings_outlined, // 임시 아이콘 (돼지 저금통)
                      size: huge,
                      color: Colors.pinkAccent.shade100, // 임시 색상
                      // TODO: 앱 테마에 맞는 의미있는 색상으로 변경 (예: Theme.of(context).colorScheme.primary)
                    ),
                    const SizedBox(height: xLarge),

                    // 사용자 안내 문구
                    Text(
                      '필수항목 및 선택 항목 약관에 동의해 주세요.',
                      textAlign: TextAlign.center, // 텍스트 중앙 정렬
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium?.fontSize ??
                                medium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: medium),

                    // 약관 동의 폼 (체크박스 및 '다음' 버튼 포함)
                    const TermsForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
