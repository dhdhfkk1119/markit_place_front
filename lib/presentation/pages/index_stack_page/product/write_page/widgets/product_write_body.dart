import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/product/write_page/widgets/product_write_item.dart';

class ProductWriteBody extends StatefulWidget {
  // final Product? product; // 수정할 상품 정보 (nullable)

  const ProductWriteBody({super.key});

  @override
  State<ProductWriteBody> createState() => _ProductWriteBodyState();
}

class _ProductWriteBodyState extends State<ProductWriteBody> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   // 수정 모드일 경우 데이터를 불러와 TextField에 채우기
  //   if (widget.product != null) {
  //     _titleController.text = widget.product!.title;
  //     _descriptionController.text = widget.product!.description;
  //     _priceController.text = widget.product!.price.toString();
  //     // 이미지 리스트도 초기화
  //     // imageList = widget.product!.images;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomWidget.buildIcon(
          onPressed: () {
            Navigator.pop(context);
          },
          const Icon(CupertinoIcons.back),
        ),
        title: CustomWidget.buildTitle("내 상품등록하기"),
        actions: const [
          // 오른쪽에 붙이는 아이콘
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ProductWriteItem(),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          ),
          child: CustomWidget.buildTitle("작성완료", color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
