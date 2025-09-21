import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/assets.dart';
import '../../../../../../domain/product/providers/product_detail_notifier.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final productId;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onBack;
  final VoidCallback onMore;

  const DetailAppBar({
    super.key,
    required this.productId,
    required this.backgroundColor,
    required this.iconColor,
    required this.onBack,
    required this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final itemAsync = ref.watch(productDetailProvider(productId));
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Left 영역
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: Icon(CupertinoIcons.back, color: iconColor),
                ),
                Text(
                  "커뮤니티",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: Assets.Fonts.cookieRun,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Right 영역
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.profile_circled,
                      color: Colors.black),
                ),
                itemAsync.when(
                  data: (item) {
                    final isFavorite = item.liked;
                    return IconButton(
                      icon: Icon(
                        isFavorite
                            ? CupertinoIcons.heart_solid
                            : CupertinoIcons.heart,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        // 서버에 좋아요 요청
                        await ref
                            .read(productDetailProvider(productId).notifier)
                            .toggleFavorite(productId);

                        // 상세 데이터 새로고침
                        ref.invalidate(productDetailProvider(productId));
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => IconButton(
                    onPressed: null,
                    icon: const Icon(CupertinoIcons.heart),
                  ),
                ),
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
