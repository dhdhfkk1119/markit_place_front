// detail_item_image.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/constants/assets.dart'; // 기본 이미지 에셋 경로를 위해 추가

import '../../../../../../domain/product/dtos/product_detail_dto.dart';
import 'fullscreen_gallery.dart';

class DetailItemImage extends StatefulWidget {
  final ProductDetailDto productDetail;

  const DetailItemImage({
    super.key,
    required this.productDetail,
  });

  @override
  State<DetailItemImage> createState() => _DetailItemImageState();
}

class _DetailItemImageState extends State<DetailItemImage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    imagePaths = widget.productDetail.imageUrls!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = imagePaths[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        imagePaths: imagePaths,
                        initialIndex: _currentIndex,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    _buildImage(imageUrl),
                    if (widget.productDetail.status == "SOLD")
                      _buildSoldOverlay(),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomWidget.buildTitle(
                "${_currentIndex + 1}/${imagePaths.length}",
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Base64 또는 네트워크 이미지를 처리하는 함수
  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          print('Network image load failed: $error');
          return _buildDefaultImage();
        },
      );
    } else {
      // Handle Base64 image
      final imageBytes = base64ToBytes(imageUrl);

      if (imageBytes == null) {
        return _buildDefaultImage();
      }

      try {
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } catch (e) {
        print('Base64 이미지 디코딩 실패: $e');
        return _buildDefaultImage();
      }
    }
  }

  // 기본 이미지를 만드는 헬퍼 함수
  Widget _buildDefaultImage() {
    return Image.asset(
      Assets.Images.logo,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  // SOLD 오버레이를 만드는 헬퍼 함수
  Widget _buildSoldOverlay() {
    return Stack(
      children: [
        // 반투명 배경
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        Center(
          child: Transform.rotate(
            angle: -45 * (3.1415926535 / 240), // -45도 회전
            child: Container(
              width: 250, // 대각선 길이 조절
              height: 60,
              child: Center(
                child: CustomWidget.buildTitle(
                  "SOLD",
                  size: 50,
                  color: Colors.white,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
