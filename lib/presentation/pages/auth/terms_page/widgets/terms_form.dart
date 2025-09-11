import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/_core/constants/theme.dart'; // 앱 전체 테마 관련 상수 (kAppPrimaryColor 등)
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart'; // 하단 '다음' 버튼 위젯

// 데이터 모델: 개별 약관 항목의 구조를 정의합니다.
class TermItem {
  final String id;
  final String title;
  final bool isMandatory; // 필수 동의 여부
  bool isAgreed; // 현재 동의 상태

  TermItem({
    required this.id,
    required this.title,
    required this.isMandatory,
    this.isAgreed = false,
  });
}

// 위젯: 여러 약관 항목에 대한 동의 UI 및 관련 로직을 관리합니다.
class TermsForm extends StatefulWidget {
  const TermsForm({super.key});

  @override
  State<TermsForm> createState() => _TermsFormState();
}

class _TermsFormState extends State<TermsForm> {
  // 실제 약관 목록 데이터입니다.
  final List<TermItem> _terms = [
    TermItem(id: 'T001', title: '서비스 이용약관', isMandatory: true),
    TermItem(id: 'T002', title: '개인정보 수집/이용 동의', isMandatory: true),
    TermItem(id: 'T003', title: '개인정보 제3자 정보제공 동의', isMandatory: true),
    TermItem(id: 'T004', title: '위치기반 서비스 이용약관 동의', isMandatory: true),
    TermItem(id: 'T005', title: '마케팅 정보 수신 동의', isMandatory: false),
  ];

  bool _isAllAgreed = false; // '전체동의' 체크박스의 상태를 관리합니다.

  @override
  void initState() {
    super.initState();
    _updateAllAgreedState(); // 초기 전체 동의 상태를 업데이트합니다.
  }

  // 모든 약관 항목의 동의 상태를 기반으로 '전체동의' 상태를 업데이트합니다.
  void _updateAllAgreedState() {
    _isAllAgreed = _terms.every((term) => term.isAgreed);
  }

  // '전체동의' 체크박스 값 변경 시 호출됩니다.
  void _onAllAgreedChanged(bool? newValue) {
    if (newValue == null) return;
    setState(() {
      _isAllAgreed = newValue;
      // 모든 개별 약관의 동의 상태를 '전체동의' 상태와 일치시킵니다.
      for (var term in _terms) {
        term.isAgreed = newValue;
      }
    });
  }

  // 개별 약관 항목의 체크박스 값 변경 시 호출됩니다.
  void _onTermAgreedChanged(String termId, bool? newValue) {
    if (newValue == null) return;
    setState(() {
      final termIndex = _terms.indexWhere((term) => term.id == termId);
      if (termIndex != -1) {
        _terms[termIndex].isAgreed = newValue;
        _updateAllAgreedState(); // 개별 항목 변경 후 전체 동의 상태를 다시 확인합니다.
      }
    });
  }

  // 약관 상세 보기 기능 (현재는 콘솔 출력)
  // TODO: 약관 상세 내용을 보여주는 다이얼로그 또는 별도 페이지 구현 필요
  void _viewTermDetails(String title) {
    print('$title 상세보기 클릭됨');
  }

  // '다음' 버튼 클릭 시 호출됩니다.
  void _onNextButtonPressed() {
    // 모든 필수 약관에 동의했는지 확인합니다.
    final allMandatoryAgreed =
        _terms.where((term) => term.isMandatory).every((term) => term.isAgreed);

    if (allMandatoryAgreed) {
      Navigator.pushNamed(context, '/register'); // 회원가입 페이지로 이동
    } else {
      // 필수 약관 미동의 시 SnackBar로 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '필수 약관에 모두 동의해주세요.',
            style: TextStyle(fontFamily: "CookieRun"),
          ),
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
        // '전체동의' UI 부분
        Container(
          decoration: BoxDecoration(
            color: kAppSecondaryColor,
            borderRadius: BorderRadius.circular(small),
          ),
          child: CheckboxListTile(
            title: Text(
              '전체동의',
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: "CookieRun",
                fontSize: medium,
              ),
            ),
            value: _isAllAgreed, // '전체동의' 상태와 연결
            onChanged: _onAllAgreedChanged, // '전체동의' 상태 변경 콜백 연결
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: theme.colorScheme.primary,
            checkColor: Colors.white,
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: small, vertical: xxSmall),
          ),
        ),
        const SizedBox(height: medium),
        // 개별 약관 목록을 표시하는 ListView
        ListView.separated(
          shrinkWrap: true, // 내용만큼만 높이를 차지하도록 설정
          physics:
              const NeverScrollableScrollPhysics(), // ListView 자체 스크롤 비활성화 (Column 내에서 사용)
          itemCount: _terms.length,
          itemBuilder: (context, index) {
            final term = _terms[index];
            // 각 약관 항목을 _TermItemRow 위젯으로 표시
            return _TermItemRow(
              term: term,
              onAgreedChanged: (bool? newValue) =>
                  _onTermAgreedChanged(term.id, newValue),
              onViewDetails: () => _viewTermDetails(term.title),
            );
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: small), // 항목 사이 간격
        ),
        const SizedBox(height: medium),
        // 하단의 '다음'으로 넘어가는 버튼 (CustomSubmitButton 외부 위젯 사용)
        CustomButtonLarge(
          text: "다음",
          onPressed: _onNextButtonPressed,
        ),
        const SizedBox(height: small),
      ],
    );
  }
}

// Private 위젯: 개별 약관 항목의 UI를 담당합니다.
class _TermItemRow extends StatelessWidget {
  final TermItem term; // 표시할 약관 데이터
  final ValueChanged<bool?> onAgreedChanged; // 동의 상태 변경 콜백
  final VoidCallback onViewDetails; // 상세보기 콜백

  const _TermItemRow({
    required this.term,
    required this.onAgreedChanged,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            // 필수 항목일 경우 '필수' 뱃지 표시
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
                    fontFamily: "CookieRun",
                  ),
                ),
              ),
            Expanded(
              child: Text(
                term.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: "CookieRun",
                ),
              ),
            ),
            const SizedBox(width: small),
            // '보기' 버튼 (약관 상세 보기 기능과 연결)
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerRight,
              ),
              onPressed: onViewDetails,
              child: Text(
                '보기',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: "CookieRun",
                ),
              ),
            ),
          ],
        ),
        value: term.isAgreed, // 약관 동의 상태와 연결
        onChanged: onAgreedChanged, // 약관 동의 상태 변경 콜백 연결
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: theme.colorScheme.primary,
        checkColor: Colors.white,
        dense: true,
      ),
    );
  }
}
