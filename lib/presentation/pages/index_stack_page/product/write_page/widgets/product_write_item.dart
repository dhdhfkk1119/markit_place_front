import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/_core/constants/size.dart';
import 'package:markit_place_front/domain/providers/product_item_notifier.dart';

class ProductWriteItem extends ConsumerStatefulWidget {
  final void Function(bool) onGetStatus;
  const ProductWriteItem(this.onGetStatus, {super.key});

  @override
  ConsumerState<ProductWriteItem> createState() => _ProductWriteItemState();
}

class _ProductWriteItemState extends ConsumerState<ProductWriteItem> {
  bool _isOn = false;
  bool _isLoading = false;
  Timer? _animationTimer;
  double _rotateValue = 0;
  final int _imageIndex = 0;
  final int _maxImageUpload = 10;
  List<XFile> imageList = [];

  void Function(bool)? onError;

  @override
  void initState() {
    super.initState();
    ref.read(productItemProvider.notifier).subscribe(userId: 1);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    if (_imageIndex >= _maxImageUpload) return; // 최대 이미지 수 초과 시 종료

    final picker = ImagePicker();
    final pickedFile = await picker.pickMultiImage(); // 갤러리에서 이미지 선택

    if (pickedFile.isNotEmpty) {
      setState(() {
        for (int i = 0; i < pickedFile.length; i++) {
          if (pickedFile[i].path.isNotEmpty) imageList.add(pickedFile[i]);
        }
        ref.read(productItemProvider.notifier).uploadImages(
            images: pickedFile,
            isOn: _isOn,
            onError = (error) {
              setState(() {
                _isLoading = !error;
              });
            });
        _isLoading = true;
        widget.onGetStatus(_isLoading);
        startLoadingAnimation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch를 build 메소드 최상단에서 한 번만 호출합니다.
    final productItemModel = ref.watch(productItemProvider);

    if (_isOn && _isLoading) {
      return Stack(
        children: [
          ListView(
            children: [
              _buildAiController(),
              _buildImageUpload(productItemModel),
              _buildProductInfo(productItemModel),
            ],
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Center(
            child: Container(
              width: getScreenWidth(context) * 0.8,
              height: getScreenHeight(context) * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                        transform: Matrix4.rotationZ(_rotateValue),
                        alignment: Alignment.center,
                        child: Image.asset(
                          Assets.Images.geminiLogo,
                          height: 70,
                          width: 70,
                        )),
                    SizedBox(height: 20),
                    CustomWidget.buildTitle("AI가 분석 중입니다..."),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        _buildAiController(),
        _buildImageUpload(productItemModel),
        _buildProductInfo(productItemModel),
      ],
    );
  }

  void startLoadingAnimation() {
    _handleLoadingAnimation();
  }

  void stopLoadingAnimation() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLoadingAnimation() {
    _animationTimer?.cancel();

    if (_isLoading) {
      _animationTimer =
          Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (!_isLoading) {
          timer.cancel();
          return;
        }

        setState(() {
          _rotateValue += 0.1;
        });
      });
    }
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

  // ProductItemModel을 파라미터로 받도록 수정합니다.
  Widget _buildImageUpload(ProductItemModel productItemModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Add image button (only shown if not at max)
          if (_imageIndex < _maxImageUpload)
            InkWell(
              onTap: _uploadImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.camera_fill,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${productItemModel.imageCount}/$_maxImageUpload",
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
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
                Positioned(
                    left: 30,
                    bottom: 30,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            imageList.remove(imagePath);
                            ref
                                .read(productItemProvider.notifier)
                                .cancelUploadImages(images: imageList);
                          });
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                        )))
              ]),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ProductItemModel을 파라미터로 받도록 수정합니다.
  Widget _buildProductInfo(ProductItemModel productItemModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("제목", size: 14),
        ),
        TextField(
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
          decoration: InputDecoration(
              hintText: productItemModel.price.toString() ?? 'W 상품 가격을 입력해주세요',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
      ],
    );
  }
}
