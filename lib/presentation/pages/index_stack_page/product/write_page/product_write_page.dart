import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../domain/product/providers/product_category_notifier.dart';
import '../../../../../domain/product/providers/product_item_notifier.dart';
import '../../../../../domain/product/providers/product_write_notifier.dart';
import 'widgets/product_write_body.dart';

import '../../../../../_core/constants/custom_widget.dart';

class ProductWritePage extends ConsumerStatefulWidget {
  const ProductWritePage({super.key});

  @override
  ConsumerState<ProductWritePage> createState() => _ProductWritePageState();
}

class _ProductWritePageState extends ConsumerState<ProductWritePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: CustomWidget.buildIcon(
            onPressed: () => Navigator.pop(context),
            const Icon(CupertinoIcons.back),
          ),
          title: CustomWidget.buildTitle("내 상품등록하기"),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: ProductWriteBody(),
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  Future<void> _handleProductSubmit(ProductItemModel productItem) async {
    final authState = ref.read(authNotifierProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    if (productItem.name.isEmpty ||
        productItem.description.isEmpty ||
        productItem.price == null ||
        productItem.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 항목을 입력해주세요.')),
      );
      return;
    }

    try {
      await ref.read(productWriteProvider.notifier).writeProduct(
            selectedCategoryId: selectedCategoryId!,
            title: productItem.name,
            content: productItem.description,
            price: productItem.price!,
            images: productItem.images,
            memberAddressId: authState.user!.memberId,
          );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품이 성공적으로 등록되었습니다!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상품 등록 실패: $e')),
      );
    }
  }

  Widget _buildSubmitButton() {
    final productItem = ref.watch(productItemProvider);
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: productItem.isLoading
              ? null
              : () => _handleProductSubmit(productItem),
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          child: CustomWidget.buildTitle(
              productItem.isLoading ? "작성 중..." : "작성완료",
              color: Colors.white,
              size: 20),
        ),
      ),
    );
  }
}
