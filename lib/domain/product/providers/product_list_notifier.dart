import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dtos/product_list_dtos.dart';
import '../models/product_list.dart';
import '../repository/product_list_repository.dart';

class ProductListNotifier extends ChangeNotifier {
  final ProductListRepository _repository = ProductListRepository();

  List<ProductListDto> _productList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductListDto> get productList => _productList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getProductList() async {
    // 1. 로딩 상태 시작
    _isLoading = true;
    _errorMessage = null; // 이전 에러 메시지 초기화
    notifyListeners(); // 로딩 상태 변화를 구독자에게 알림

    try {
      final response = await _repository.productList();

      final List<dynamic> content = response['content'];

      _productList = content
          .map((json) => ProductList.fromJson(json))
          .map((model) => ProductListDto.fromModel(model))
          .toList();

      // 4. 호출 성공 시 로딩 상태 종료
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }
}

final productListProvider =
    ChangeNotifierProvider<ProductListNotifier>((ref) => ProductListNotifier());
