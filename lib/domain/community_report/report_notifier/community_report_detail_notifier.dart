import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_dto/community_report_dto.dart';
import '../report_model/community_report_model.dart';
import '../report_repository/community_report_repository.dart';

class CommunityReportDetailNotifier
    extends FamilyAsyncNotifier<CommunityReportDto, int> {
  final CommunityReportRepository _reportRepository =
      CommunityReportRepository();

  @override
  Future<CommunityReportDto> build(int reportId) async {
    try {
      final response = await _reportRepository.reportDetail(reportId: reportId);
      final communityReport =
          CommunityReportModel.fromJson(response['response']);
      final dto = CommunityReportDto.fromModel(communityReport);
      return dto;
    } catch (e) {
      throw Exception("서버를 연결할수없습니다");
    }
  }
}

final communityReportDetailProvider = AsyncNotifierProvider.family<
    CommunityReportDetailNotifier, CommunityReportDto, int>(
  () => CommunityReportDetailNotifier(),
);
