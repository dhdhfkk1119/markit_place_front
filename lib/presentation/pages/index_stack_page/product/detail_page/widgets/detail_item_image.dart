import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

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
          // 화면 내 썸네일 슬라이드
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  // 클릭 시 전체 화면 확대+슬라이드
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
                // 경로에 있는 이미지 보여주기(index 리스트 형식으로)
                child: Image.asset(
                  widget.imagePaths[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
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
}
