import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';

// 데이터: 개별 약관 항목 정의
class TermItem {
  final String id; // 고유 식별자
  final String title; // 제목
  final bool isMandatory; // 필수 동의 여부
  bool isAgreed; // 동의 상태

  TermItem({
    required this.id,
    required this.title,
    required this.isMandatory,
    this.isAgreed = false, // 기본값: 미동의
  });
}

// 위젯: 약관 동의 UI 및 로직 관리
class TermsForm extends StatefulWidget {
  const TermsForm({super.key});

  @override
  State<TermsForm> createState() => _TermsFormState();
}

class _TermsFormState extends State<TermsForm> {
  // 상태: 약관 목록 (실제 앱에서는 외부 주입 또는 상태 관리 고려)
  final List<TermItem> _terms = [
    TermItem(id: 'T001', title: '서비스 이용약관', isMandatory: true),
    TermItem(id: 'T002', title: '개인정보 수집/이용 동의', isMandatory: true),
    TermItem(id: 'T003', title: '개인정보 제3자 정보제공 동의', isMandatory: true),
    TermItem(id: 'T004', title: '위치기반 서비스 이용약관 동의', isMandatory: true),
    TermItem(id: 'T005', title: '마케팅 정보 수신 동의', isMandatory: false),
  ];

  // 상태: '전체 동의' 체크박스 값
  bool _isAllAgreed = false;

  @override
  void initState() {
    super.initState();
    _updateAllAgreedState(); // 로직: 초기 전체 동의 상태 계산
  }

  // 로직: 전체 동의 상태 업데이트 (_terms 기반)
  void _updateAllAgreedState() {
    _isAllAgreed = _terms.every((term) => term.isAgreed);
  }

  // 로직: '전체 동의' 체크박스 값 변경 시 처리
  void _onAllAgreedChanged(bool? newValue) {
    if (newValue == null) return;
    setState(() {
      _isAllAgreed = newValue;
      // 로직: 모든 개별 약관 동의 상태 일괄 변경
      for (var term in _terms) {
        term.isAgreed = newValue;
      }
    });
  }

  // 로직: 개별 약관 동의 상태 변경 시 처리
  void _onTermAgreedChanged(String termId, bool? newValue) {
    if (newValue == null) return;
    setState(() {
      final termIndex = _terms.indexWhere((term) => term.id == termId);
      if (termIndex != -1) {
        _terms[termIndex].isAgreed = newValue;
        _updateAllAgreedState(); // 로직: 개별 변경 후 전체 동의 상태 재계산
      }
    });
  }

  // 로직: 약관 '보기' 버튼 클릭 (상세 내용 표시)
  void _viewTermDetails(String title) {
    // TODO: 약관 상세 내용을 보여주는 다이얼로그 또는 별도 페이지 구현
    print('$title 상세보기 클릭됨');
  }

  // 로직: '다음' 버튼 클릭 (필수 약관 동의 확인 후 페이지 이동)
  void _onNextButtonPressed() {
    // 로직: 모든 '필수' 약관 동의 여부 확인
    final allMandatoryAgreed =
        _terms.where((term) => term.isMandatory).every((term) => term.isAgreed);

    if (allMandatoryAgreed) {
      Navigator.pushNamed(context, '/register'); // 라우팅: 회원가입 페이지로
    } else {
      // UI 피드백: 필수 약관 미동의 시 SnackBar 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 모두 동의해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // UI 구성: '전체 동의' 섹션
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: small, vertical: xSmall),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(xSmall),
          ),
          child: CheckboxListTile(
            title: Text(
              '전체동의',
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      theme.textTheme.titleSmall?.fontFamily ?? "CookieRun"),
            ),
            value: _isAllAgreed,
            onChanged: _onAllAgreedChanged, // 콜백: 전체 동의 상태 변경
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: theme.colorScheme.primary,
            dense: true,
          ),
        ),
        const SizedBox(height: medium),

        // UI 구성: 개별 약관 목록
        ListView.separated(
          shrinkWrap: true, // 스크롤: 내부 컨텐츠 크기에 맞춰 높이 조절
          physics:
              const NeverScrollableScrollPhysics(), // 스크롤: ListView 자체 스크롤 비활성화
          itemCount: _terms.length,
          itemBuilder: (context, index) {
            final term = _terms[index];
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: xxSmall, vertical: xxSmall / 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(xSmall),
              ),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: xSmall),
                title: Row(
                  children: [
                    // UI 조건부 렌더링: 필수 약관 태그
                    if (term.isMandatory)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: small, vertical: xxSmall),
                        margin: const EdgeInsets.only(right: small),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(xxSmall),
                        ),
                        child: Text(
                          '필수',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontFamily:
                                  theme.textTheme.labelSmall?.fontFamily ??
                                      "CookieRun"),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        term.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily:
                                theme.textTheme.bodyMedium?.fontFamily ??
                                    "CookieRun"),
                      ),
                    ),
                    const SizedBox(width: small),
                    // UI 버튼: 약관 '보기'
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(36, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerRight,
                      ),
                      onPressed: () =>
                          _viewTermDetails(term.title), // 콜백: 약관 상세 보기
                      child: Text(
                        '보기',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: theme.textTheme.bodySmall?.fontFamily ??
                                "CookieRun"),
                      ),
                    ),
                  ],
                ),
                value: term.isAgreed,
                onChanged: (bool? newValue) =>
                    _onTermAgreedChanged(term.id, newValue), // 콜백: 개별 동의 상태 변경
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: theme.colorScheme.primary,
                dense: true,
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: small),
        ),
        const SizedBox(height: medium),

        // UI 버튼: '다음'
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: theme.elevatedButtonTheme.style?.copyWith(
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: medium)),
              textStyle: MaterialStateProperty.all(theme.textTheme.labelLarge
                  ?.copyWith(
                      fontWeight:
                          theme
                              .elevatedButtonTheme.style?.textStyle
                              ?.resolve({})?.fontWeight,
                      color: theme.elevatedButtonTheme.style?.foregroundColor
                          ?.resolve({}),
                      fontFamily: theme.textTheme.labelLarge?.fontFamily ??
                          "CookieRun")),
            ),
            onPressed: _onNextButtonPressed, // 콜백: 다음 단계 진행
            child: const Text('다음'),
          ),
        ),
        const SizedBox(height: small),
      ],
    );
  }
}
