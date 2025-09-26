import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_repository/community_report_repository.dart';
import 'community_report_list_notifier.dart';

class CommunityReportNotifier extends AutoDisposeAsyncNotifier<void> {
  final _repository = CommunityReportRepository();

  @override
  Future<void> build() async {}

  Future<void> saveCommunityReport({
    required int postId,
    required String reason,
  }) async {
    state = const AsyncLoading();

    try {
      await _repository.reportSaveCommunity(postId, reason);
      await ref
          .read(communityReportListNotifier.notifier)
          .refreshReportCommunityList();

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

final communityReportProvider =
    AutoDisposeAsyncNotifierProvider<CommunityReportNotifier, void>(
        () => CommunityReportNotifier());
