import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/product/dtos/product_list_dtos.dart';
import '../../../../../../domain/product/dtos/product_search_dto.dart';
import '../../../../../../domain/product/providers/product_list_notifier.dart';
import '../../../../../../domain/product/providers/product_sort_state_provider.dart';
import 'product_filter_list.dart';
import 'product_list_item.dart';
import '../../../../../widgets/WriteButton.dart';

class ProductListBody extends ConsumerStatefulWidget {
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
  ConsumerState<ProductListBody> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends ConsumerState<ProductListBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final notifier = ref.read(productListProvider.notifier);

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(productListProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(productListProvider.notifier).refreshProductList();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductListDto>> productListState =
        ref.watch(productListProvider);
    final productListNotifier = ref.read(productListProvider.notifier);

    return SafeArea(
      child: Stack(
        children: [
          productListState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('에러 발생: $error')),
            data: (productList) {
              return Row(
                children: [
                  if (widget.isFilterVisible)
                    const SizedBox(
                      width: 170,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ProductFilterList(),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: productList.isEmpty
                          ? const Center(
                              child: Text(
                                "리스트가 없습니다.",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount: productList.length +
                                  (productListState.isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < productList.length) {
                                  final product = productList[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ProductListItem(
                                        product, widget.isFilterVisible),
                                  );
                                } else {
                                  // 마지막에 로딩 인디케이터 표시 (hasNext가 true일 때만)
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                              },
                              separatorBuilder: (_, __) => const Divider(
                                height: 32,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (widget.isSearchVisible)
            Positioned(
              top: 0,
              left: widget.isFilterVisible ? 170 : 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                      hintText: "검색어를 입력하세요",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          productListNotifier.searchProducts(
                            ProductSearchDTO(
                                keyword: widget.searchController.text),
                          );
                        },
                        child: Icon(Icons.send),
                      )),
                ),
              ),
            ),
          WriteButton(
            onTap: widget.onWritePressed,
            title: "상품등록",
          ),
        ],
      ),
    );
  }
}
