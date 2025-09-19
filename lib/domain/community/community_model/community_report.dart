enum CommunityReportStatus {
  PENDING,
  IN_PROGRESS,
  RESOLVED,
  REJECTED,
}

class CommunityReportDTO {
  final int? id;
  final String? message;
  final int? postId;
  final String? reason;
  final CommunityReportStatus? status;
  final String? createdAt;
  final int? reporterId;
  final String? postTitle;
  final String? postContent;

  CommunityReportDTO({
    this.id,
    this.message,
    this.postId,
    this.reason,
    this.status,
    this.createdAt,
    this.reporterId,
    this.postTitle,
    this.postContent,
  });


  factory CommunityReportDTO.fromModel(CommunityReportDTO model) {
    return CommunityReportDTO(
      id: model.id,
      message: model.message,
      postId: model.postId,
      reason: model.reason,
      status: model.status,
      createdAt: model.createdAt,
      reporterId: model.reporterId,
    );
  }
}