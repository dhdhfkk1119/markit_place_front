import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/community/community_dto/community_list_dto.dart';
import 'package:markit_place_front/domain/community/community_model/community_list.dart';
import 'package:markit_place_front/domain/community/community_repository/community_list_repository.dart';

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
    notifyListeners(); // 로딩 상태 변화를 구독자에게 알림

    try {
      final response = await _communityListRepository.communityList();

      final List<dynamic> list = response['response'];

      _communityList = list
          .map((json) => CommunityList.fromMap(json))
          .map((model) => CommunityListDTO.fromModel(model))
          .toList();
      _isLoading = false;

      print("Notifier: Repository에서 받은 최종 데이터");
      print("데이터 개수: ${_communityList.length}");
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }
}

final communityListProvider = ChangeNotifierProvider<CommunityListNotifier>(
    (ref) => CommunityListNotifier());
