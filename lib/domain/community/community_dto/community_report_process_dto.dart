import 'package:markit_place_front/domain/community/community_dto/community_report_dto.dart';

class CommunityReportProcessDTO {
  final int? processId;
  final int? reportId;
  final int? postId;
  final String? postTitle;
  final CommunityReportStatus? status;
  final String? createdAt;

  final String? postContent;
  final String? reporterName;
  final String? reason;

  CommunityReportProcessDTO({
    this.processId,
    this.reportId,
    this.postId,
    this.postTitle,
    this.status,
    this.createdAt,
    this.postContent,
    this.reporterName,
    this.reason,
  });


  factory CommunityReportProcessDTO.fromJson(Map<String, dynamic> json) {
    return CommunityReportProcessDTO(
      processId: json['processId'] as int?,
      reportId: json['reportId'] as int?,
      postId: json['postId'] as int?,
      postTitle: json['postTitle'] as String,
      status: CommunityReportStatus.values.firstWhere(
              (element) =>
          element.toString() == 'CommunityReportStatus.${json['status']}',
          orElse: () => CommunityReportStatus.PENDING),
      createdAt: json['createdAt'] as String,
      postContent: json['postContent'] as String,
      reporterName: json['reporterName'] as String,
      reason: json['reason'] as String,
    );
  }
}
