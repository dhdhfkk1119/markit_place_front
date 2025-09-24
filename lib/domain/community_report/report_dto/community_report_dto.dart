import '../report_model/community_report_model.dart';

enum CommunityReportStatus { PENDING, REJECTED, APPROVED }

class CommunityReportDto {
  final int id;
  final int postId;
  final String reason;
  final CommunityReportStatus status;
  final String createdAt;
  final bool? hasNext;

  CommunityReportDto({
    required this.id,
    required this.postId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.hasNext = true,
  });

  factory CommunityReportDto.fromModel(CommunityReportModel model) {
    return CommunityReportDto(
      id: model.id,
      postId: model.postId,
      reason: model.reason,
      status: model.status,
      createdAt: model.createdAt,
    );
  }

  CommunityReportDto copyWith({
    int? id,
    int? postId,
    String? reason,
    CommunityReportStatus? status,
    String? createdAt,
  }) {
    return CommunityReportDto(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
