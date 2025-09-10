import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onBack;
  final VoidCallback onMore;

  const DetailAppBar({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.onBack,
    required this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
                  fontFamily: "CookieRun",
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
              IconButton(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.heart, color: Colors.black),
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
  }
}
