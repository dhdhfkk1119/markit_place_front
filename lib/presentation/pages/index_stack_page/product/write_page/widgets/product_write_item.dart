import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/constants/size.dart';
import '../../../../../../domain/product/dtos/product_detail_dto.dart';
import '../../../../../../domain/product/providers/product_category_notifier.dart';
import '../../../../../../domain/product/providers/product_item_notifier.dart';
import '../../../../../../domain/product/providers/product_write_notifier.dart';

import '../../../../../../_core/utils/notification_util.dart';

class ProductWriteItem extends ConsumerStatefulWidget {
  ProductDetailDto? model;
  ProductWriteItem({this.model, super.key});

  @override
  ConsumerState<ProductWriteItem> createState() => _ProductWriteItemState();
}

class _ProductWriteItemState extends ConsumerState<ProductWriteItem>
    with SingleTickerProviderStateMixin {
  final int _maxImageUpload = 10;

  late final AnimationController _animationController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    ref.read(productCategoryProvider.notifier);

    ref.read(productItemProvider.notifier).subscribe(userId: 1);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    final initialModel = ref.read(productItemProvider);
    _titleController = TextEditingController(
        text: widget.model?.productList.title ?? initialModel.name);
    _descriptionController = TextEditingController(
        text: widget.model?.productList.content ?? initialModel.description);
    _priceController = TextEditingController(
        text: widget.model?.productList.price.toString() ??
            initialModel.price?.toString() ??
            "");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void listenNotifications() {
    NotificationUtil.notificationStream.stream.listen((String? payload) {
      if (payload != null && mounted) {
        print("Received payload: $payload");
        Navigator.pushNamed(context, "/message", arguments: payload);
      }
    });
  }

  Future<void> _uploadImage() async {
    final productItemModel = ref.read(productItemProvider);
    final currentImageCount = productItemModel.images.length;
    if (currentImageCount >= _maxImageUpload) return;

    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      ref
          .read(productItemProvider.notifier)
          .uploadImages(images: pickedFiles, isOn: productItemModel.isOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productItemModel = ref.watch(productItemProvider);

    ref.listen(productItemProvider, (prev, next) {
      if (prev?.name != next.name) {
        _titleController.text = next.name;
      }

      if (prev?.streamingText != next.streamingText &&
          next.streamingText.isNotEmpty) {
        _descriptionController.value = TextEditingValue(
          text: next.streamingText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: next.streamingText.length),
          ),
        );
      }

      if (prev?.description != next.description &&
          next.description.isNotEmpty) {
        _descriptionController.value = TextEditingValue(
          text: next.description,
          selection: TextSelection.fromPosition(
            TextPosition(offset: next.description.length),
          ),
        );
      }

      if (prev?.price != next.price) {
        _priceController.text = next.price.toString();
      }
    });

    if (productItemModel.isOn && productItemModel.isLoading) {
      _animationController.repeat(period: const Duration(seconds: 2));
    } else {
      _animationController.stop();
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildAiController(),
                const SizedBox(height: 16),
                _buildImageUpload(productItemModel, dto: widget.model),
                _buildProductInfo(productItemModel),
              ],
            ),
          ),
          if (productItemModel.isOn && productItemModel.isLoading)
            _buildLoadingOverlay(context, productItemModel),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(
      BuildContext context, ProductItemModel productItemModel) {
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
                      CustomWidget.buildTitle(productItemModel.thinkingMessage),
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
    final isOn = ref.watch(productItemProvider.select((model) => model.isOn));

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
                      value: isOn,
                      activeColor: Colors.white, // 슬라이드 버튼 원 색
                      activeTrackColor: Colors.deepPurpleAccent, // 활성화 배경
                      inactiveThumbColor: Colors.grey.shade200, // 비활성화 원 색
                      inactiveTrackColor: Colors.grey.shade400, // 비활성화 배경
                      onChanged: (value) {
                        ref.read(productItemProvider.notifier).setOn(value);
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

  Widget _buildImageUpload(ProductItemModel productItemModel,
      {ProductDetailDto? dto}) {
    // 모델에서 가져온 이미지 (로컬 업로드된 이미지들)
    final localImages = productItemModel.images;

    // 서버에서 받아온 기존 이미지들 (URL)
    final networkImages = dto?.imageUrls ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (localImages.length + networkImages.length < _maxImageUpload)
            InkWell(
              onTap: _uploadImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.camera_fill,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${localImages.length + networkImages.length}/$_maxImageUpload",
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
          const SizedBox(width: 15),

          // 서버에서 받아온 이미지 (기존 등록된 상품 이미지)
          ...networkImages.map((base64Str) {
            final bytes = base64ToBytes(base64Str);
            if (bytes == null) {
              return const SizedBox(); // 혹은 기본 placeholder 이미지
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(bytes),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: -35,
                    right: -35,
                    child: IconButton(
                      onPressed: () {
                        // 서버에서 받은 base64 이미지 삭제
                        ref
                            .read(productItemProvider.notifier)
                            .removeImage(base64Str as XFile);
                      },
                      icon: const Icon(
                        Icons.cancel,
                        color: Color.fromARGB(255, 179, 0, 0),
                      ),
                    ),
                  )
                ],
              ),
            );
          }).toList(),

          // 로컬에서 업로드한 이미지 (XFile or File)
          ...localImages.map((imagePath) {
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
                  top: -35,
                  right: -35,
                  child: IconButton(
                    onPressed: () {
                      ref
                          .read(productItemProvider.notifier)
                          .removeImage(imagePath);
                    },
                    icon: const Icon(Icons.cancel,
                        color: Color.fromARGB(255, 179, 0, 0)),
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
          onChanged: (text) {
            ref.read(productItemProvider.notifier).updateName(text);
          },
          decoration: InputDecoration(
              hintText: productItemModel.isOn
                  ? 'AI가 추천한 제목이 여기에 표시됩니다.'
                  : '상품의 제목을 입력해주세요',
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
          onChanged: (text) {
            ref.read(productItemProvider.notifier).updateDescription(text);
          },
          decoration: InputDecoration(
              hintText: productItemModel.isOn
                  ? 'AI가 추천한 상품 설명이 여기에 표시됩니다.'
                  : '상품의 설명을 입력해주세요',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("판매 가격", size: 14),
        ),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          onChanged: (text) {
            final price = int.tryParse(text) ?? 0;
            ref.read(productItemProvider.notifier).updatePrice(price);
            print('로그: 가격 입력됨 -> ${price}');
          },
          decoration: InputDecoration(
              hintText: '상품의 가격을 입력해주세요',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: IntrinsicWidth(
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return _buildCategorySelector(context);
                  },
                );
              },
              child: Row(
                children: [
                  CustomWidget.buildTitle(
                      _selectedCategoryName ?? "상품 카테고리를 선택해주세요",
                      size: 16,
                      weight: FontWeight.w500),
                  SizedBox(
                    width: 8,
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final asyncCategories = ref.watch(productCategoryProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              children: [
                Icon(Icons.title, size: 24, color: Colors.deepPurpleAccent),
                CustomWidget.buildTitle("카테고리를 선택해주세요", size: 18),
              ],
            ),
          ),
          asyncCategories.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('카테고리 로딩 에러: $err')),
            data: (categories) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: categories.map((category) {
                      return _buildListItem(category.name, category.id);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.grey,
                    weight: 20,
                  ),
                  const SizedBox(width: 32),
                  CustomWidget.buildTitle("닫기"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(String text, int id) {
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    bool isSelected = selectedCategoryId == id;

    return TextButton(
      onPressed: () {
        ref.read(selectedCategoryIdProvider.notifier).state = id;

        setState(() {
          _selectedCategoryName = text;
        });
        print("해당 상품의 번호 , 이름 ${id} , ${text}");
        Navigator.pop(context);
      },
      child: CustomWidget.buildTitle(text,
          color: isSelected ? Colors.white : Colors.black,
          weight: FontWeight.w200,
          size: 14),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
