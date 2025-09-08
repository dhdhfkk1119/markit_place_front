import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

class ProductWriteItem extends StatefulWidget {
  const ProductWriteItem({super.key});

  @override
  State<ProductWriteItem> createState() => _ProductWriteItemState();
}

class _ProductWriteItemState extends State<ProductWriteItem> {
  bool _isOn = false;
  int _imageIndex = 0;
  int _maxImageUpload = 10;
  List<String?> imageList = [];

  Future<void> _uploadImage() async {
    if (_imageIndex >= _maxImageUpload) return; // 최대 이미지 수 초과 시 종료

    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택

    if (pickedFile != null) {
      setState(() {
        imageList.add(pickedFile.path);
        _imageIndex = imageList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildAiController(),
        _buildImageUpload(),
        _buildProductInfo(),
      ],
    );
  }

  Widget _buildAiController() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(bottom: 16),
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
                  Icon(CupertinoIcons.staroflife_fill,
                      size: 14, color: Colors.deepPurpleAccent),
                  SizedBox(
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

  Widget _buildImageUpload() {
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
                    Icon(
                      CupertinoIcons.camera_fill,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "$_imageIndex/$_maxImageUpload",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ...imageList.map((imagePath) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("제목", size: 14),
        ),
        TextField(
          decoration: InputDecoration(
              hintText: '제목',
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
              hintText:
                  '여기는 상품에 대한 정보가 담기느 부분입니다 판매 금지 된 물품이나 등록 선정에 부적절한 물픔은 등록을 삼가 해주시기바랍니다 ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("자세한 설명", size: 14),
        ),
        TextField(
          decoration: InputDecoration(
              hintText: 'W 상품 가격을 입력해주세요',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
      ],
    );
  }
}
