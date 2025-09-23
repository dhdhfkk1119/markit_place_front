// detail_item_image.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/constants/assets.dart'; // 기본 이미지 에셋 경로를 위해 추가

import 'fullscreen_gallery.dart';

class DetailItemImage extends StatefulWidget {
  final List<String> imagePaths;

  const DetailItemImage({
    super.key,
    required this.imagePaths,
  });

  @override
  State<DetailItemImage> createState() => _DetailItemImageState();
}

class _DetailItemImageState extends State<DetailItemImage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = widget.imagePaths[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        imagePaths: widget.imagePaths,
                        initialIndex: _currentIndex,
                      ),
                    ),
                  );
                },
                child: _buildImage(imageUrl),
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
                "${_currentIndex + 1}/${widget.imagePaths.length}",
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
    final imageBytes = base64ToBytes(imageUrl);

    if (imageBytes == null) {
      return _buildDefaultImage();
    }
    return Image.memory(
      imageBytes,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  // 기본 이미지를 만드는 헬퍼 함수
  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Icon(
          Icons.photo,
          size: 80,
          color: Colors.black,
        ),
      ),
    );
  }
}
