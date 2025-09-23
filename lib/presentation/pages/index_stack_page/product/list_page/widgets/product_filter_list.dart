import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/product/dtos/product_search_dto.dart';
import '../../../../../../domain/product/models/product_category.dart';
import '../../../../../../domain/product/providers/product_category_notifier.dart';
import '../../../../../../domain/product/providers/product_list_notifier.dart';
import '../../../../../../domain/product/providers/product_sort_state_provider.dart';
import '../../../../../widgets/custom_text_form_field.dart';
import 'filter_item.dart';

class ProductFilterList extends ConsumerStatefulWidget {
  const ProductFilterList({super.key});

  @override
  ConsumerState<ProductFilterList> createState() => _ProductFiterListState();
}

class _ProductFiterListState extends ConsumerState<ProductFilterList> {
  String _sortBy = 'latest';
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryList = ref.watch(productCategoryProvider);
    final selectedId = ref.watch(selectedCategoryIdProvider);
    final productListNotifier = ref.read(productListProvider.notifier);

    return categoryList.when(
      data: (List<ProductCategory> categoryList) {
        return SizedBox.expand(
          child: ListView(
            children: [
              _buildTitleSection(
                title: '필터',
                onReset: () {
                  ref.read(selectedCategoryIdProvider.notifier).state = null;
                  setState(() {
                    _sortBy = 'latest';
                  });
                  productListNotifier.refreshProductList();
                },
              ),
              _buildSortButtons(),
              const Divider(height: 1, thickness: 1),
              _buildTitleSection(title: '카테고리'),
              ...categoryList.map((category) {
                return FilterItemWidget(
                  title: category.name,
                  initialValue: selectedId == category.id,
                  onChanged: (bool newValue) {
                    if (newValue) {
                      ref.read(selectedCategoryIdProvider.notifier).state =
                          category.id;
                      productListNotifier.searchProducts(
                        ProductSearchDTO(itemCategoryId: category.id),
                      );
                    } else {
                      ref.read(selectedCategoryIdProvider.notifier).state =
                          null;
                      productListNotifier.refreshProductList();
                    }
                  },
                );
              }).toList(),
              const Divider(height: 1, thickness: 1),
              _buildTitleSection(title: '가격 정렬'),
              _buildMinPrice(),
              _buildMaxPrice(),
              _buildApplyFilterButton(context, ref),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("카테고리 로드 오류: $error")),
    );
  }

  Widget _buildSortButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final productListNotifier = ref.read(productListProvider.notifier);
        final selectedSortOption = ref.watch(sortOptionProvider);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                ref.read(sortOptionProvider.notifier).state = 'latest';
                productListNotifier.searchProducts(
                  ProductSearchDTO(sortBy: 'latest'),
                );
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '최신순',
                style: TextStyle(
                  color: selectedSortOption == 'latest'
                      ? Colors.black
                      : Colors.grey,
                  fontWeight: selectedSortOption == 'latest'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(sortOptionProvider.notifier).state = 'popular';
                productListNotifier.searchProducts(
                  ProductSearchDTO(sortBy: 'popular'),
                );
              },
              child: Text(
                '인기순',
                style: TextStyle(
                  color: selectedSortOption == 'popular'
                      ? Colors.black
                      : Colors.grey,
                  fontWeight: selectedSortOption == 'popular'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMinPrice() {
    return Consumer(
      builder: (context, ref, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.buildTitle(
              "최소 가격 : ",
              size: 14,
              weight: FontWeight.w200,
            ),
            SizedBox(
              height: 40,
              child: CustomTextFormField(
                controller: _minPriceController,
                hint: "최소가격 입력",
                onChanged: (value) {
                  final price = int.tryParse(value);
                  ref.read(minPriceProvider.notifier).state = price;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMaxPrice() {
    return Consumer(
      builder: (context, ref, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.buildTitle("최대 가격 : ",
                size: 14, weight: FontWeight.w200),
            SizedBox(
              height: 40,
              child: CustomTextFormField(
                controller: _maxPriceController,
                hint: "최대가격 입력",
                onChanged: (value) {
                  final price = int.tryParse(value);
                  ref.read(maxPriceProvider.notifier).state = price;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 이전에 만들었던 '필터 적용' 버튼을 사용합니다.
  Widget _buildApplyFilterButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final minPrice = ref.read(minPriceProvider);
        final maxPrice = ref.read(maxPriceProvider);
        final sortBy = ref.read(sortOptionProvider);

        ref.read(productListProvider.notifier).searchProducts(
              ProductSearchDTO(
                minPrice: minPrice,
                maxPrice: maxPrice,
                sortBy: sortBy,
              ),
            );
      },
      child: Text('필터 적용'),
    );
  }

  Widget _buildTitleSection({required String title, VoidCallback? onReset}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTitle(title),
        if (onReset != null)
          TextButton(
            onPressed: onReset,
            child: Text(
              "초기화",
              style: TextStyle(
                  fontFamily: Assets.Fonts.cookieRun,
                  color: Colors.grey,
                  decoration: TextDecoration.underline),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}
