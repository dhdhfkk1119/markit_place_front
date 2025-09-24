import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../report/report_notifier/product_report_list_notifier.dart';
import '../report_dto/community_report_dto.dart';
import '../report_repository/community_report_repository.dart';

class CommunityReportListNotifier
    extends AsyncNotifier<List<CommunityReportDto>> {
  final CommunityReportRepository _repository = CommunityReportRepository();

  @override
  Future<List<CommunityReportDto>> build() async {
    final response = await _repository.reportMyPost();
    final List<dynamic> content = response['response'];
    return content.map((json) => CommunityReportDto.fromModel(json)).toList();
  }

  Future<void> refreshReportCommunityList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final communityReportListNotifier = AsyncNotifierProvider<
    CommunityReportListNotifier,
    List<CommunityReportDto>>(() => CommunityReportListNotifier());
