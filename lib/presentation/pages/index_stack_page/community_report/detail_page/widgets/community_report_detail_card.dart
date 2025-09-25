import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../domain/community/community_dto/community_detail_dto.dart';

class CommunityReportDetailCard extends StatelessWidget {
  final CommunityDetailDto post;

  const CommunityReportDetailCard({super.key, required this.post});

  String truncateString(String text, int length) {
    return (text.length <= length) ? text : '${text.substring(0, length)}...';
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildDefaultImage();
    }

    final imageBytes = base64ToBytes(imageUrl);

    if (imageBytes == null) {
      return _buildDefaultImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 72,
        height: 72,
      ),
    );
  }

  // 기본 아이콘 이미지
  Widget _buildDefaultImage() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.article_outlined,
        size: 34,
        color: Color(0xFFBDBDBD),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          _buildImage(
            post.images != null && post.images!.isNotEmpty
                ? post.images!.first
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.isNotEmpty ? post.title : '제목 없음',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  post.content.isNotEmpty
                      ? truncateString(post.content, 50)
                      : '내용 없음',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.location.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      post.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
