import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';

class ReportListItem extends StatelessWidget {
  const ReportListItem(
      {super.key,
      required this.title,
      required this.reason,
      required this.status,
      required this.createdAt,
      this.thumbnailUrl,
      this.onTap});

  final String title;
  final String reason;
  final String status;
  final String createdAt;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  String _label(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
        return '보류중';
      case 'IN_PROGRESS':
        return '처리중';
      case 'BAD_RESOLVED':
        return '제재완료';
      case 'RESOLVED':
        return '기각';
      default:
        return s;
    }
  }

  Color _color(String s) {
    final l = _label(s);
    if (l == '보류중') return Colors.purple;
    if (l == '처리중') return Colors.orange;
    if (l == '제재완료') return Colors.blue;
    return Colors.grey;
  }

  Widget _thumbnail(String? src) {
    if (src == null || src.isEmpty) {
      return const Center(child: Icon(Icons.photo, color: Colors.grey));
    }
    // data:image/...;base64,xxxx 처리
    if (src.startsWith('data:image')) {
      final int comma = src.indexOf(',');
      final String b64 = comma >= 0 ? src.substring(comma + 1) : src;
      final Uint8List bytes = base64Decode(b64);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    // http/https URL 처리
    return CachedNetworkImage(
      imageUrl: src,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(child: Icon(Icons.image)),
      errorWidget: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _thumbnail(thumbnailUrl),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _color(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _label(status),
                          style: TextStyle(
                            color: _color(status),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(createdAt,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
