import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../detail_page/community_detail_page.dart';

class CommunityListItem extends StatefulWidget {
  final bool _isFilterVisible;
  const CommunityListItem(this._isFilterVisible, {super.key});

  @override
  State<CommunityListItem> createState() => _CommunityListItemState();
}

class _CommunityListItemState extends State<CommunityListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          // 2. MaterialPageRoute를 사용하여 새로운 페이지(DetailPage)를 정의합니다.
          MaterialPageRoute(
            builder: (context) =>
                const CommunityDetailPageDetailPage(), // DetailPage()는 상세 페이지 위젯입니다.
          ),
        );
      },
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            Expanded(child: _buildProductInfo()),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _buildProductImage(),
                  ],
                ),
                Column(
                  children: [
                    _buildBottomIcon(),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // 상품에대한 대표 이미지를 만드는 함수
  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        "assets/lun.jpg",
        width: 75,
        height: 75,
        scale: 1,
      ),
    );
  }

  // 상품에 대한 정보를 담음 함수(제목, 위치,가격)
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4), // 텍스트 주변 여백
          decoration: BoxDecoration(
            color: Colors.grey.shade200, // 회색 배경
            borderRadius: BorderRadius.circular(8), // 모서리 둥글게
          ),
          child: const Text(
            "운동",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        _buildTitle("러닝 같이 하실분 구합니다 ", 16),
        _buildTitle(
            "러닝 같이 하실분 구합니다러닝 같이 하실분 구합니다러닝 같이 하실분 구합니다러닝 같이 하실분 구합니다러닝 같이 하실분 구합니다러닝 같이 하실분 구합니다러닝 같이 하실분 구합니다",
            12,
            font: FontWeight.w200,
            color: Colors.grey),
        const Spacer(),
        _buildTitle(
          "등록위치 º 조회수 158",
          12,
          font: FontWeight.w100,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildTitle(String title, double size,
      {FontWeight? font, Color? color}) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: "CookieRun",
        fontSize: size,
        color: color ?? Colors.black,
        fontWeight: font ?? FontWeight.w700,
      ),
    );
  }

  Widget _buildBottomIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildIcon(CupertinoIcons.heart),
        _buildTitle("14", 12, font: FontWeight.w200, color: Colors.grey),
        const SizedBox(
          width: 8,
        ),
        _buildIcon(Icons.comment),
        _buildTitle("14", 12, font: FontWeight.w200, color: Colors.grey),
      ],
    );
  }

  Widget _buildIcon(IconData? icon) {
    return Icon(
      icon,
      size: 14,
      color: Colors.grey,
    );
  }
}
