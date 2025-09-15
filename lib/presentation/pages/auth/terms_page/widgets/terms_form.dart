import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/_core/constants/theme.dart';
import 'package:markit_place_front/presentation/widgets/custom_button_large.dart';
import 'package:markit_place_front/domain/terms/models/term.dart';
import 'package:markit_place_front/domain/terms/providers/terms_provider.dart';

import '../../../../../_core/constants/assets.dart';

class TermsForm extends ConsumerStatefulWidget {
  const TermsForm({super.key});

  @override
  ConsumerState<TermsForm> createState() => _TermsFormState();
}

class _TermsFormState extends ConsumerState<TermsForm> {
  late Map<int, bool> _agreedState;
  bool _isAllAgreed = false;

  @override
  void initState() {
    super.initState();
    _agreedState = {};
  }

  void _updateAllAgreedState(List<Term> currentTerms) {
    if (currentTerms.isEmpty) {
      _isAllAgreed = false;
      return;
    }
    _isAllAgreed = currentTerms.every((term) => _agreedState[term.id] ?? false);
  }

  void _onAllAgreedChanged(bool? newValue, List<Term> currentTerms) {
    if (newValue == null || currentTerms.isEmpty) return;
    setState(() {
      _isAllAgreed = newValue;
      for (var term in currentTerms) {
        _agreedState[term.id] = newValue;
      }
    });
  }

  void _onTermAgreedChanged(
      int termId, bool? newValue, List<Term> currentTerms) {
    if (newValue == null) return;
    setState(() {
      _agreedState[termId] = newValue;
      _updateAllAgreedState(currentTerms);
    });
  }

  void _viewTermDetails(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(title, style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        content: SingleChildScrollView(
            child: Text(content,
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
          ),
        ],
      ),
    );
  }

  void _onNextButtonPressed(List<Term> currentTerms) {
    final allMandatoryAgreed = currentTerms
        .where((term) => term.required)
        .every((term) => _agreedState[term.id] ?? false);

    if (allMandatoryAgreed) {
      final List<int> agreedIds = [];
      _agreedState.forEach((termId, isAgreed) {
        if (isAgreed) {
          agreedIds.add(termId);
        }
      });
      // RegisterPage로 이동하면서 동의한 약관 ID 목록을 arguments로 전달
      Navigator.pushReplacementNamed(context, '/register',
          arguments: agreedIds);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 약관에 모두 동의해주세요.',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final termsAsyncValue = ref.watch(termsListProvider);

    return termsAsyncValue.when(
      data: (terms) {
        if (_agreedState.isEmpty && terms.isNotEmpty ||
            _agreedState.length != terms.length && terms.isNotEmpty) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _agreedState.clear();
                for (var term in terms) {
                  _agreedState[term.id] = false;
                }
                _updateAllAgreedState(terms);
              });
            }
          });
        }

        if (terms.isEmpty && !termsAsyncValue.isLoading) {
          return Center(
              child: Text('표시할 약관이 없습니다.',
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun)));
        }
        if (termsAsyncValue.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kAppSecondaryColor,
                borderRadius: BorderRadius.circular(small),
              ),
              child: CheckboxListTile(
                title: Text(
                  '전체동의',
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: Assets.Fonts.cookieRun, fontSize: medium),
                ),
                value: _isAllAgreed,
                onChanged: (value) => _onAllAgreedChanged(value, terms),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: theme.colorScheme.primary,
                checkColor: Colors.white,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: small, vertical: xxSmall),
              ),
            ),
            const SizedBox(height: medium),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: terms.length,
              itemBuilder: (context, index) {
                final term = terms[index];
                return _TermItemRow(
                  term: term,
                  isAgreed: _agreedState[term.id] ?? false,
                  onAgreedChanged: (value) =>
                      _onTermAgreedChanged(term.id, value, terms),
                  onViewDetails: () =>
                      _viewTermDetails(term.title, term.content),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: small),
            ),
            const SizedBox(height: medium),
            CustomButtonLarge(
              text: "다음",
              onPressed: () => _onNextButtonPressed(terms),
            ),
            const SizedBox(height: small),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
          child: Text('약관을 불러올 수 없습니다: ${error.toString()}',
              style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
    );
  }
}

class _TermItemRow extends StatelessWidget {
  final Term term;
  final bool isAgreed;
  final ValueChanged<bool?> onAgreedChanged;
  final VoidCallback onViewDetails;

  const _TermItemRow({
    required this.term,
    required this.isAgreed,
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
            if (term.required)
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
                    fontFamily: Assets.Fonts.cookieRun,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                term.title,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontFamily: Assets.Fonts.cookieRun),
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
                  fontFamily: Assets.Fonts.cookieRun,
                ),
              ),
            ),
          ],
        ),
        value: isAgreed,
        onChanged: onAgreedChanged,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: theme.colorScheme.primary,
        checkColor: Colors.white,
        dense: true,
      ),
    );
  }
}
