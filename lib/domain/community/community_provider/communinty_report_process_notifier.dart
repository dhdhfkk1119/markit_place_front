import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_dto/community_report_dto.dart';
import '../community_dto/community_report_process_dto.dart';

class CommunityReportProcessNotifier
    extends StateNotifier<List<CommunityReportProcessDTO>> {
  CommunityReportProcessNotifier() : super([]);

  void updateReports(List<CommunityReportProcessDTO> newReports) {
    state = newReports;
  }

  void updateReportStatus(int reportId, CommunityReportStatus newStatus) {
    state = [
      for (final report in state)
        if (report.reportId == reportId)
          CommunityReportProcessDTO(
            processId: report.processId,
            reportId: report.reportId,
            postId: report.postId,
            postTitle: report.postTitle,
            status: newStatus,
            createdAt: report.createdAt,
            postContent: report.postContent,
            reporterName: report.reporterName,
            reason: report.reason,
          )
        else
          report,
    ];
  }

  void removeReport(int reportId) {
    state = [
      for (final report in state)
        if (report.reportId != reportId) report,
    ];
  }

  final communityReportProcessProvider = StateNotifierProvider<
      CommunityReportProcessNotifier, List<CommunityReportProcessDTO>>((ref) {
    return CommunityReportProcessNotifier();
  });
}
