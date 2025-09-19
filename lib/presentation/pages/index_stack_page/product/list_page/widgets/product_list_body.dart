import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/product/dtos/product_list_dtos.dart';
import '../../../../../../domain/product/providers/product_list_notifier.dart';
import 'product_filter_list.dart';
import 'product_list_item.dart';
import '../../../../../widgets/WriteButton.dart';

class ProductListBody extends ConsumerWidget {
  final bool isFilterVisible;
  final VoidCallback onWritePressed;
  final TextEditingController searchController;
  final bool isSearchVisible;

  const ProductListBody({
    super.key,
    required this.isFilterVisible,
    required this.onWritePressed,
    required this.isSearchVisible,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductListDto>> productListState =
        ref.watch(productListProvider);

    return productListState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
      data: (productList) {
        return SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  if (isFilterVisible)
                    const SizedBox(
                      width: 170,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ProductFilterList(),
                      ),
                    ),
                  Expanded(
                    child: productList.isEmpty
                        ? const Center(
                            child: Text(
                              "리스트가 없습니다.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: productList.length,
                            itemBuilder: (context, index) {
                              final product = productList[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    ProductListItem(product, isFilterVisible),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(
                              height: 32,
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ],
              ),
              if (isSearchVisible)
                Positioned(
                  top: 0,
                  left: isFilterVisible ? 170 : 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "검색어를 입력하세요",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (value) {
                        print("검색: $value");
                      },
                    ),
                  ),
                ),
              WriteButton(
                onTap: onWritePressed,
                title: "상품등록",
              ),
            ],
          ),
        );
      },
    );
  }
}
