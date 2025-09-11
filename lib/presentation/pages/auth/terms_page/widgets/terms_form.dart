import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/presentation/widgets/custom_submit_button.dart';

// 데이터: 개별 약관 항목 정의
class TermItem {
  final String id;
  final String title;
  final bool isMandatory;
  bool isAgreed;

  TermItem({
    required this.id,
    required this.title,
    required this.isMandatory,
    this.isAgreed = false,
  });
}

// 위젯: 약관 동의 UI 및 로직 관리
class TermsForm extends StatefulWidget {
  const TermsForm({super.key});

  @override
  State<TermsForm> createState() => _TermsFormState();
}

class _TermsFormState extends State<TermsForm> {
  final List<TermItem> _terms = [
    TermItem(id: 'T001', title: '서비스 이용약관', isMandatory: true),
    TermItem(id: 'T002', title: '개인정보 수집/이용 동의', isMandatory: true),
    TermItem(id: 'T003', title: '개인정보 제3자 정보제공 동의', isMandatory: true),
    TermItem(id: 'T004', title: '위치기반 서비스 이용약관 동의', isMandatory: true),
    TermItem(id: 'T005', title: '마케팅 정보 수신 동의', isMandatory: false),
  ];

  bool _isAllAgreed = false;

  @override
  void initState() {
    super.initState();
    _updateAllAgreedState();
  }

  void _updateAllAgreedState() {
    _isAllAgreed = _terms.every((term) => term.isAgreed);
  }

  void _onAllAgreedChanged(bool? newValue) {
    if (newValue == null) return;
    setState(() {
      _isAllAgreed = newValue;
      for (var term in _terms) {
        term.isAgreed = newValue;
      }
    });
  }

  void _onTermAgreedChanged(String termId, bool? newValue) {
    if (newValue == null) return;
    setState(() {
      final termIndex = _terms.indexWhere((term) => term.id == termId);
      if (termIndex != -1) {
        _terms[termIndex].isAgreed = newValue;
        _updateAllAgreedState();
      }
    });
  }

  void _viewTermDetails(String title) {
    // TODO: 약관 상세 내용을 보여주는 다이얼로그 또는 별도 페이지 구현
    print('$title 상세보기 클릭됨');
  }

  void _onNextButtonPressed() {
    final allMandatoryAgreed =
        _terms.where((term) => term.isMandatory).every((term) => term.isAgreed);

    if (allMandatoryAgreed) {
      Navigator.pushNamed(context, '/register');
    } else {
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
    // CustomSubmitButton의 높이와 유사하게 만들기 위한 CheckboxListTile의 내부 세로 패딩 계산
    // (목표 높이 - 텍스트 높이 - 기타 내부 패딩) / 2
    // theme.textTheme.labelLarge.fontSize가 null일 수 있으므로 기본값(medium) 제공
    final double titleFontSize = theme.textTheme.labelLarge?.fontSize ?? medium;
    // CheckboxListTile의 대략적인 상하 기본 패딩/마진을 16 (8+8) 정도로 가정
    final double checkboxListTileVerticalPadding =
        (xxLarge - titleFontSize - 16) / 2 > 0
            ? (xxLarge - titleFontSize - 16) / 2
            : small; // 계산된 패딩이 음수면 기본값 small 사용

    return Column(
      children: [
        Container(
          // Container에 직접 높이를 지정하여 CustomSubmitButton과 유사하게 만들 수도 있습니다.
          // height: xxLarge,
          padding: const EdgeInsets.symmetric(
              horizontal: small,
              vertical: 0), // CheckboxListTile이 내부 패딩을 갖도록 horizontal만 지정
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent, // CustomSubmitButton 배경색
            borderRadius:
                BorderRadius.circular(small), // CustomSubmitButton 모서리
          ),
          child: CheckboxListTile(
            title: Text(
              '전체동의',
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: "CookieRun",
                color: Colors.white,
                fontSize: medium,
                // fontWeight: FontWeight.normal, // 기존 bold에서 변경 원하시면
              ),
            ),
            value: _isAllAgreed,
            onChanged: _onAllAgreedChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.white,
            checkColor: Colors.deepPurpleAccent,
            dense: true,
            // contentPadding으로 내부 여백을 조절하여 수직 중앙 정렬 및 높이 확보 시도
            contentPadding: EdgeInsets.symmetric(
                horizontal: small, // 좌우 패딩
                vertical: checkboxListTileVerticalPadding // 계산된 상하 패딩
                ),
          ),
        ),
        const SizedBox(height: medium),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _terms.length,
          itemBuilder: (context, index) {
            final term = _terms[index];
            return _TermItemRow(
              term: term,
              onAgreedChanged: (bool? newValue) =>
                  _onTermAgreedChanged(term.id, newValue),
              onViewDetails: () => _viewTermDetails(term.title),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: small),
        ),
        const SizedBox(height: medium),
        CustomSubmitButton(
          text: "다음",
          onPressed: _onNextButtonPressed,
        ),
        const SizedBox(height: small),
      ],
    );
  }
}

// 개별 약관 항목을 표시하는 private 위젯
class _TermItemRow extends StatelessWidget {
  final TermItem term;
  final ValueChanged<bool?> onAgreedChanged;
  final VoidCallback onViewDetails;

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
        value: term.isAgreed,
        onChanged: onAgreedChanged,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: theme.colorScheme.primary,
        dense: true,
      ),
    );
  }
}
