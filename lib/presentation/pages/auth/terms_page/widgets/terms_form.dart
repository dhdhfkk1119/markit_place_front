import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/size.dart';
import '../../../../../_core/constants/theme.dart';
import '../../../../widgets/custom_button_large.dart';
import '../../../../../domain/members/models/term.dart';
import '../../../../../domain/members/providers/terms_provider.dart';
import '../../../../../_core/constants/assets.dart';

// 1. State class for the agreement logic
class TermsAgreementData {
  final Map<int, bool> agreedMap;
  final bool isAllAgreed;

  TermsAgreementData({required this.agreedMap, required this.isAllAgreed});

  TermsAgreementData.initial()
      : agreedMap = {},
        isAllAgreed = false;

  TermsAgreementData copyWith({
    Map<int, bool>? agreedMap,
    bool? isAllAgreed,
  }) {
    return TermsAgreementData(
      agreedMap: agreedMap ?? this.agreedMap,
      isAllAgreed: isAllAgreed ?? this.isAllAgreed,
    );
  }
}

// 2. StateNotifier for managing terms agreement
class TermsAgreementNotifier extends StateNotifier<TermsAgreementData> {
  final Ref _ref;
  List<Term> _currentTerms = []; // To store the latest terms

  TermsAgreementNotifier(this._ref) : super(TermsAgreementData.initial()) {
    // Listen to termsListProvider to initialize/reset agreement state when terms change
    _ref.listen<AsyncValue<List<Term>>>(termsListProvider, (previous, next) {
      next.whenData((terms) {
        _currentTerms = terms;
        if (terms.isEmpty) {
          state = TermsAgreementData(agreedMap: {}, isAllAgreed: false);
        } else {
          // Initialize only if the terms list has actually changed structure
          // or if the map is currently empty for these terms.
          bool needsReinitialization = state.agreedMap.isEmpty ||
              !state.agreedMap.keys.every((k) => terms.any((t) => t.id == k)) ||
              !terms.every((t) => state.agreedMap.containsKey(t.id));

          if (needsReinitialization) {
            final newAgreedMap = {for (var term in terms) term.id: false};
            state =
                TermsAgreementData(agreedMap: newAgreedMap, isAllAgreed: false);
          }
        }
      });
    });
  }

  void _recalculateAllAgreed() {
    if (_currentTerms.isEmpty) {
      state = state.copyWith(isAllAgreed: false);
      return;
    }
    final allAgreed =
        _currentTerms.every((term) => state.agreedMap[term.id] ?? false);
    state = state.copyWith(isAllAgreed: allAgreed);
  }

  void toggleTerm(int termId, bool? newValue) {
    if (newValue == null || !state.agreedMap.containsKey(termId)) return;
    final newMap = Map<int, bool>.from(state.agreedMap);
    newMap[termId] = newValue;
    state = state.copyWith(agreedMap: newMap);
    _recalculateAllAgreed();
  }

  void toggleAll(bool? newValue) {
    if (newValue == null || _currentTerms.isEmpty) return;
    final newMap = {for (var term in _currentTerms) term.id: newValue};
    state = TermsAgreementData(agreedMap: newMap, isAllAgreed: newValue);
  }

  List<int>? getAgreedTermIdsForNavigation() {
    if (_currentTerms.isEmpty && state.agreedMap.isEmpty) {
      // If there were no terms to begin with, and thus nothing to agree to.
      // This case might mean proceeding is allowed if no terms are mandatory.
      // Or, if terms were expected, this indicates an issue (handled by terms.isEmpty check in UI).
      // For safety, let's assume if currentTerms is empty, it means no mandatory terms were missed.
      return [];
    }

    final allMandatoryAgreed = _currentTerms
        .where((term) => term.required)
        .every((term) => state.agreedMap[term.id] ?? false);

    if (allMandatoryAgreed) {
      final List<int> agreedIds = [];
      state.agreedMap.forEach((termId, isAgreed) {
        if (isAgreed) {
          agreedIds.add(termId);
        }
      });
      return agreedIds;
    }
    return null;
  }
}

final termsAgreementNotifierProvider =
    StateNotifierProvider<TermsAgreementNotifier, TermsAgreementData>((ref) {
  return TermsAgreementNotifier(ref);
});

// 3. Refactored TermsForm as ConsumerWidget
class TermsForm extends ConsumerWidget {
  const TermsForm({super.key});

  void _viewTermDetails(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:
            Text(title, style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
        content: SingleChildScrollView(
            child: Text(content,
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('닫기',
                style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final termsAsyncValue = ref.watch(termsListProvider);
    final agreementState = ref.watch(termsAgreementNotifierProvider);
    final agreementNotifier = ref.read(termsAgreementNotifierProvider.notifier);

    return termsAsyncValue.when(
      data: (terms) {
        // Notifier initializes based on terms data, no need for Future.microtask here.

        if (terms.isEmpty) {
          // Simplified check based on actual terms list
          return Center(
              child: Text('표시할 약관이 없습니다.',
                  style: TextStyle(fontFamily: Assets.Fonts.cookieRun)));
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
                value: agreementState.isAllAgreed,
                onChanged: (value) => agreementNotifier.toggleAll(value),
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
                  isAgreed: agreementState.agreedMap[term.id] ?? false,
                  onAgreedChanged: (value) =>
                      agreementNotifier.toggleTerm(term.id, value),
                  onViewDetails: () =>
                      _viewTermDetails(context, term.title, term.content),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: small),
            ),
            const SizedBox(height: medium),
            CustomButtonLarge(
              text: "다음",
              onPressed: () {
                final agreedIds =
                    agreementNotifier.getAgreedTermIdsForNavigation();
                if (agreedIds != null) {
                  Navigator.pushReplacementNamed(context, '/register',
                      arguments: agreedIds);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('필수 약관에 모두 동의해주세요.',
                          style: TextStyle(fontFamily: Assets.Fonts.cookieRun)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
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

// _TermItemRow widget remains unchanged
class _TermItemRow extends StatelessWidget {
  final Term term;
  final bool isAgreed;
  final ValueChanged<bool?> onAgreedChanged;
  final VoidCallback onViewDetails;

  const _TermItemRow({
    super.key,
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
