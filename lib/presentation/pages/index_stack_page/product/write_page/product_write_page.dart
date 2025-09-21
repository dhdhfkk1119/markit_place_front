import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../domain/product/dtos/product_detail_dto.dart';
import '../../../../../domain/product/providers/product_category_notifier.dart';
import '../../../../../domain/product/providers/product_item_notifier.dart';
import '../../../../../domain/product/providers/product_write_notifier.dart';
import 'widgets/product_write_body.dart';

import '../../../../../_core/constants/custom_widget.dart';

class ProductWritePage extends ConsumerStatefulWidget {
  ProductDetailDto? model;
  ProductWritePage({this.model, super.key});

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
            child: ProductWriteBody(model: widget.model),
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  Future<void> _handleProductSubmit(ProductItemModel productItem) async {
    final authState = ref.read(authNotifierProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    // 기존 값 보정
    final title = productItem.name.isEmpty
        ? widget.model?.productList.title ?? ""
        : productItem.name;

    final description = productItem.description.isEmpty
        ? widget.model?.productList.content ?? ""
        : productItem.description;

    final price = productItem.price ?? widget.model?.productList.price;

    // 신규 작성일 때만 "빈값 검사" 강제
    if (widget.model == null &&
        (title.isEmpty || description.isEmpty || price == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필수 항목을 입력해주세요.')),
      );
      return;
    }

    try {
      if (widget.model == null) {
        // 신규 작성
        await ref.read(productWriteProvider.notifier).writeProduct(
              selectedCategoryId: selectedCategoryId!,
              title: title,
              content: description,
              price: price!,
              images: productItem.images,
              memberAddressId: authState.user!.memberId,
              tradeLocation: authState.user!.name,
            );
      } else {
        // 수정하기
        await ref.read(productWriteProvider.notifier).updateProduct(
              productId: widget.model!.productList.id,
              selectedCategoryId:
                  selectedCategoryId ?? widget.model!.itemCategoryId,
              title: title,
              content: description,
              price: price!,
              images: productItem.images,
              memberAddressId: authState.user!.memberId,
              tradeLocation: authState.user!.name,
            );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상품 처리 실패: $e')),
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
            productItem.isLoading
                ? (widget.model == null ? "작성 중..." : "수정 중...")
                : (widget.model == null ? "작성완료" : "수정완료"),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
