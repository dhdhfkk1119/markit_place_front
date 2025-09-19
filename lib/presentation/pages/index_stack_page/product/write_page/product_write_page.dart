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
  final _priceController = TextEditingController(); // It was missing!
  int? _selectedCategoryId;

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

  Future<void> _handleProductSubmit() async {
    final productItemModel = ref.read(productItemProvider);
    final selectedCategoryId = ref.read(selectedCategoryIdProvider);
    final authState = ref.read(authNotifierProvider);

    if (productItemModel.images.isEmpty ||
        _priceController.text.isEmpty ||
        selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    try {
      await ref.read(productWriteProvider.notifier).writeProduct(
            selectedCategoryId: selectedCategoryId,
            title: productItemModel.name, // Using AI-generated name
            content:
                productItemModel.description, // Using AI-generated description
            price: int.parse(_priceController.text),
            images: productItemModel.images,
            memberId: authState.user!.memberId,
          );

      // 3. Navigate back on success
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product successfully submitted!')),
      );
    } catch (e) {
      // 4. Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    }
  }

  // Inside _buildSubmitButton()
  Widget _buildSubmitButton() {
    final productItem = ref.watch(productItemProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          // Call the new method here
          onPressed: () {
            print("해당 상품의 번호 , 이름 ${selectedCategoryId}");
          },
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
