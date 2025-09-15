import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/providers/product_item_notifier.dart';

class ProductWriteItem extends ConsumerStatefulWidget {
  const ProductWriteItem({super.key});

  @override
  ConsumerState<ProductWriteItem> createState() => _ProductWriteItemState();
}

class _ProductWriteItemState extends ConsumerState<ProductWriteItem>
    with SingleTickerProviderStateMixin {
  bool _isOn = false;
  final int _maxImageUpload = 10;

  late final AnimationController _animationController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    ref.read(productItemProvider.notifier).subscribe(userId: 1);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    final initialModel = ref.read(productItemProvider);
    _titleController = TextEditingController(text: initialModel.title);
    _descriptionController =
        TextEditingController(text: initialModel.description);
    _priceController =
        TextEditingController(text: initialModel.price?.toString() ?? "");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    final currentImageCount = ref.read(productItemProvider).images.length;
    if (currentImageCount >= _maxImageUpload) return;

    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      ref
          .read(productItemProvider.notifier)
          .uploadImages(images: pickedFiles, isOn: _isOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productItemModel = ref.watch(productItemProvider);

    ref.listen(productItemProvider, (prev, next) {
      if (prev?.title != next.title) {
        _titleController.text = next.title ?? '';
      }
      if (prev?.description != next.description) {
        _descriptionController.text = next.description ?? '';
      }
      if (prev?.price != next.price) {
        _priceController.text = next.price?.toString() ?? '';
      }
    });

    if (_isOn && productItemModel.isLoading) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildAiController(),
              const SizedBox(height: 16),
              _buildImageUpload(productItemModel),
              _buildProductInfo(productItemModel),
            ],
          ),
        ),
        if (_isOn && productItemModel.isLoading) _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: getScreenWidth(context) * 0.8,
            height: getScreenHeight(context) * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _animationController,
                        child: Image.asset(
                          Assets.Images.geminiLogo,
                          height: 70,
                          width: 70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomWidget.buildTitle("AI가 분석 중입니다..."),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon:
                        const Icon(Icons.cancel, color: Colors.black, size: 30),
                    onPressed: () {
                      ref
                          .read(productItemProvider.notifier)
                          .cancelSubscription();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiController() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.staroflife_fill,
                      size: 14, color: Colors.deepPurpleAccent),
                  const SizedBox(
                    width: 4,
                  ),
                  CustomWidget.buildTitle("AI로 작성하기",
                      size: 14, color: Colors.deepPurpleAccent)
                ],
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _isOn,
                      activeColor: Colors.white, // 슬라이드 버튼 원 색
                      activeTrackColor: Colors.deepPurpleAccent, // 활성화 배경
                      inactiveThumbColor: Colors.grey.shade200, // 비활성화 원 색
                      inactiveTrackColor: Colors.grey.shade400, // 비활성화 배경
                      onChanged: (value) {
                        setState(() {
                          _isOn = value;
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload(ProductItemModel productItemModel) {
    final imageList = productItemModel.images;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (imageList.length < _maxImageUpload)
            InkWell(
              onTap: _uploadImage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.camera_fill,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${productItemModel.images.length}/$_maxImageUpload",
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          ...imageList.map((imagePath) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(File(imagePath.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        ref
                            .read(productItemProvider.notifier)
                            .removeImage(imagePath);
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white),
                    ),
                  ),
                )
              ]),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ProductItemModel productItemModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("제목", size: 14),
        ),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
              hintText: productItemModel.title ?? '제목',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("자세한 설명", size: 14),
        ),
        TextField(
          maxLines: null,
          minLines: 5,
          controller: _descriptionController,
          decoration: InputDecoration(
              hintText: productItemModel.description ??
                  '여기는 상품에 대한 정보가 담기느 부분입니다 판매 금지 된 물품이나 등록 선정에 부적절한 물픔은 등록을 삼가 해주시기바랍니다 ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("판매 가격", size: 14),
        ),
        TextField(
          controller: _priceController,
          decoration: InputDecoration(
              hintText: productItemModel.price.toString() ?? 'W 상품 가격을 입력해주세요',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
      ],
    );
  }
}
