import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../domain/community/community_model/community_list.dart';
import '../../detail_page/community_detail_page.dart';

class CommunityListItem extends StatefulWidget {
  final CommunityList list;
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
          MaterialPageRoute(
            builder: (context) => CommunityDetailPage(postId: widget.list.id),
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
                _buildCommunityImage(widget.list),
                _buildBottomIcon(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityImage(CommunityList list) {
    final serverImageBytes = list.thumbnail != null ? base64ToBytes(list.thumbnail!) : null;
    final bytesToDisplay = serverImageBytes ?? base64ToBytes(kDefaultThumbnailBase64);

    if (bytesToDisplay == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 75,
          height: 75,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        bytesToDisplay,
        width: 75,
        height: 75,
        scale: 1,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCommunityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.list.topic,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
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
