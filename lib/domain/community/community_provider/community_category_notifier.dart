import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/community/community_dto/community_category_dto.dart';
import '../community_repository/community_category_repository.dart';

class CommunityCategoryNotifier extends ChangeNotifier {
  final CommunityCategoryRepository _communityCategoryRepository =
  CommunityCategoryRepository();

  List<CommunityCategoryDTO> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityCategoryDTO> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<CommunityCategoryDTO> list =
      await _communityCategoryRepository.getCategories();
      _categories = list;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error fetching categories: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final communityCategoryProvider =
ChangeNotifierProvider<CommunityCategoryNotifier>(
        (ref) => CommunityCategoryNotifier());