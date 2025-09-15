import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/providers/product_item_notifier.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/write_page/widgets/product_write_body.dart';

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

  Widget _buildSubmitButton() {
    final productItem = ref.watch(productItemProvider);

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {},
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
