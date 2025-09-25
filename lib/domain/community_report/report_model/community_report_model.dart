import '../report_dto/community_report_dto.dart';

class CommunityReportModel {
  final int id;
  final int postId;
  final String reason;
  final CommunityReportStatus status;
  final String createdAt;

  CommunityReportModel({
    required this.id,
    required this.postId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory CommunityReportModel.fromJson(Map<String, dynamic> json) {
    return CommunityReportModel(
      id: json['id'],
      postId: json['postId'],
      reason: json['reason'],
      status: CommunityReportStatus.values
          .firstWhere((status) => status.name == json['status']),
      createdAt: json['createdAt'],
    );
  }
}
