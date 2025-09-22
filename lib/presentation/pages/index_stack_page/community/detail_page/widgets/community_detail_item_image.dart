import 'package:flutter/material.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_widget.dart';

import 'community_fullscreen_gallery.dart';

class CommunityDetailItemImage extends StatefulWidget {
  final List<String> imagePaths;
  const CommunityDetailItemImage({
    super.key,
    required this.imagePaths,
  });

  @override
  State<CommunityDetailItemImage> createState() =>
      _CommunityDetailItemImageState();
}

class _CommunityDetailItemImageState extends State<CommunityDetailItemImage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print("게시물 이미지 리스트 : ${widget.imagePaths}");
    if (widget.imagePaths.isEmpty) {
      return _buildDefaultImage();
    }
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
                      builder: (_) => CommunityFullscreenGallery(
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
          // 현재 페이지 표시
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

  // 기본 이미지를 만드는 헬퍼 함수
  Widget _buildDefaultImage() {
    return const Center(child: CircularProgressIndicator());
  }
}
