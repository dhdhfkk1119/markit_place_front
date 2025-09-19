import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/product/providers/product_list_notifier.dart';
import 'product_list_item.dart';

class ProductListView extends ConsumerWidget {
  final bool isFilterVisible;

  const ProductListView({
    super.key,
    required this.isFilterVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. `ref.watch`를 사용하여 `AsyncValue` 상태를 가져옵니다.
    final productListState = ref.watch(productListProvider);

    // 2. `.when()` 메서드로 상태에 따라 UI를 분기합니다.
    return productListState.when(
      // 로딩 중일 때
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      // 에러가 발생했을 때
      error: (error, stackTrace) => Center(
        child: Text('에러 발생: $error'),
      ),
      // 데이터가 있을 때
      data: (productList) {
        if (productList.isEmpty) {
          return const Center(
            child: Text(
              "리스트가 없습니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ProductListItem(product, isFilterVisible),
            );
          },
          separatorBuilder: (_, __) => const Divider(
            height: 32,
            thickness: 1,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
