import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_category.dart';
import '../repository/product_category_repository.dart';

// Provider 인스턴스 생성
final productCategoryRepositoryProvider =
    Provider((ref) => ProductCategoryRepository());

// 상태 관리를 위한 AsyncNotifierProvider 정의
final productCategoryProvider =
    AsyncNotifierProvider<ProductCategoryNotifier, List<ProductCategory>>(() {
  return ProductCategoryNotifier();
});

class ProductCategoryNotifier extends AsyncNotifier<List<ProductCategory>> {
  @override
  Future<List<ProductCategory>> build() async {
    final repository = ref.read(productCategoryRepositoryProvider);

    // API 응답을 받습니다.
    final response = await repository.productCategoryList();

    return response.map((data) => ProductCategory.fromJson(data)).toList();
  }
}

final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);
