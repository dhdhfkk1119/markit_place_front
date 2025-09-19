import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/community/community_dto/community_report_dto.dart';
import 'package:markit_place_front/domain/community/community_repository/community_report_repository.dart';

class CommunityReportModel {
  final List<CommunityReportDTO> reports;
  final bool isLoading;

  CommunityReportModel({
    required this.reports,
    this.isLoading = false,
  });

  CommunityReportModel copyWith({
    List<CommunityReportDTO>? reports,
    bool? isLoading,
  }) {
    return CommunityReportModel(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CommunityReportNotifier extends StateNotifier<CommunityReportModel> {
  final CommunityReportRepository _repository;

  CommunityReportNotifier(this._repository)
      : super(CommunityReportModel(reports: []));

  Future<String?> fetchReports() async {
    try {
      state = state.copyWith(isLoading: true);
      ResponseDTO responseDTO = await _repository.getReports();

      if (responseDTO.status == 200) {
        if (responseDTO.data is List) {
          List<CommunityReportDTO> reports = (responseDTO.data as List)
              .map((e) => CommunityReportDTO.fromJson(e))
              .toList();

          state = state.copyWith(
            reports: reports,
            isLoading: false,
          );
          return null;
        } else {
          state = state.copyWith(isLoading: false);
          return '데이터 형식이 올바르지 않습니다.';
        }
      } else {
        state = state.copyWith(isLoading: false);
        return '오류 : ${responseDTO.message}';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print(e);
      return '신고 목록을 가져오는데 실패 했습니다.';
    }
  }
}