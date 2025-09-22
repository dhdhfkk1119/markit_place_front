import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../domain/community/community_dto/community_list_dto.dart';
import '../../../../../../domain/community/community_model/community_list.dart';

import '../../../../../../domain/product/dtos/product_list_dtos.dart';
import '../../detail_page/community_detail_page.dart';

class CommunityListItem extends StatefulWidget {
  final CommunityListDTO list;
  final bool isFilterVisible;

  const CommunityListItem(this.list, this.isFilterVisible, {super.key});

  @override
  State<CommunityListItem> createState() => _CommunityListItemState();
}

class _CommunityListItemState extends State<CommunityListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("해당 게시글의 ID: ${widget.list.id}");
        Navigator.push(
          context,
          // 2. MaterialPageRoute를 사용하여 새로운 페이지(DetailPage)를 정의합니다.
          MaterialPageRoute(
            builder: (context) => CommunityDetailPageDetailPage(
                postId: widget.list.id), // DetailPage()는 상세 페이지 위젯입니다.
          ),
        );
      },
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            Expanded(child: _buildCommunityInfo()),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _buildCommunityImage(widget.list),
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

  // 게시글에 대한 대표 이미지를 만드는 함수
  Widget _buildCommunityImage(CommunityListDTO list) {
    final imageBytes = base64ToBytes(list.thumbnail);

    if (imageBytes == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          Assets.Images.community2,
          width: 75,
          height: 75,
          scale: 1,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        imageBytes,
        width: 75,
        height: 75,
        scale: 1,
      ),
    );
  }

  // 게시글에 대한 정보를 담음 함수(제목, 위치,가격)
  Widget _buildCommunityInfo() {
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
          child: Text(
            "${widget.list.topic}",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        _buildTitle(widget.list.title, 16),
        _buildTitle(widget.list.preview ?? "", 12,
            font: FontWeight.w200, color: Colors.grey),
        const Spacer(),
        _buildTitle(
          "${widget.list.location}º 조회수 ${widget.list.viewCount}",
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
        fontFamily: Assets.Fonts.cookieRun,
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
        _buildTitle("${widget.list.likeCount}", 12,
            font: FontWeight.w200, color: Colors.grey),
        const SizedBox(
          width: 8,
        ),
        _buildIcon(Icons.comment),
        _buildTitle("${widget.list.commentCount}", 12,
            font: FontWeight.w200, color: Colors.grey),
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
