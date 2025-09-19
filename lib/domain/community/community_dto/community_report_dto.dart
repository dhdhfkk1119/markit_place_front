import '../community_dto/community_report_dto.dart';

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

  factory CommunityReportDTO.fromJson(Map<String, dynamic> json) {
    return CommunityReportDTO(
      id: json["id"] as int?,
      message: json["message"] as String?,
      postId: json["postId"] as int?,
      reporterId: json["reporterId"] as int?,
      reason: json["reason"] as String?,
      status: CommunityReportStatus.values.firstWhere(
          (element) =>
              element.toString() == 'CommunityReportStatus.${json["status"]}',
          orElse: () => CommunityReportStatus.PENDING),
      createdAt: json["createdAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "postId": postId,
      "reason": reason,
    };
  }
}

class ResponseDTO {
  final int status;
  final String message;
  final dynamic data;

  ResponseDTO({
    required this.status,
    required this.message,
    this.data,
  });

  factory ResponseDTO.fromJson(Map<String, dynamic> json) {
    return ResponseDTO(
      status: json["status"] as int,
      message: json["message"] as String,
      data: json["data"],
    );
  }
}
