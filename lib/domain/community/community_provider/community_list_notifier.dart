import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../community_dto/community_list_dto.dart';
import '../community_model/community_list.dart';
import '../community_repository/community_list_repository.dart';

class CommunityListNotifier extends ChangeNotifier {
  final CommunityListRepository _communityListRepository =
  CommunityListRepository();

  List<CommunityListDTO> _communityList = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityListDTO> get communityList => _communityList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getCommunityList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _communityListRepository.communityList();
      final List<dynamic> list = response['response'];

      _communityList = list
          .map((json) => CommunityList.fromMap(json))
          .map((model) => CommunityListDTO.fromJson(model))
          .toList();
      _isLoading = false;

      if (kDebugMode) {
        print("CommunityListNotifier: Repository에서 받은 최종 데이터");
        print("데이터 개수: ${_communityList.length}");
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      if (kDebugMode) {
        print("CommunityListNotifier: Error fetching list - $e");
      }
    } finally {
      notifyListeners();
    }
  }

  // 좋아요 상태 및 개수 업데이트 메소드
  void updatePostLikeStatus(int postId, bool newIsLiked, int newLikeCount) {
    final index = _communityList.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _communityList[index] = _communityList[index].copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      );
      notifyListeners();
    }
  }

  // 조회수 업데이트 메소드
  void updatePostViewCount(int postId, int newViewCount) {
    final index = _communityList.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _communityList[index] = _communityList[index].copyWith(
        viewCount: newViewCount,
      );
      notifyListeners();
    }
  }
}

final communityListProvider = ChangeNotifierProvider<CommunityListNotifier>(
        (ref) => CommunityListNotifier());
