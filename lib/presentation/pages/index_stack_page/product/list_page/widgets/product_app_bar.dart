import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentTitle;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onFilterToggle;
  final VoidCallback onSearchToggle;

  const ProductListAppBar({
    super.key,
    required this.currentTitle,
    required this.onTitleChanged,
    required this.onFilterToggle,
    required this.onSearchToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(currentTitle,
              style: const TextStyle(
                fontFamily: "CookieRun",
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(width: 4),
          InkWell(
            onTap: () async {
              final newTitle = await _showLocationDialog(context);
              if (newTitle != null) onTitleChanged(newTitle);
            },
            child: const Icon(CupertinoIcons.chevron_down, size: 15.0),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.list_bullet),
          onPressed: onFilterToggle,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.profile_circled),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.search),
          onPressed: onSearchToggle,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.bell_fill),
          onPressed: () {},
        ),
      ],
    );
  }

  Future<String?> _showLocationDialog(BuildContext context) {
    return showGeneralDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: "Dialog",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                left: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPlaceItem(context, "부전제1동"),
                        _buildPlaceItem(context, "부전제2동"),
                        _buildPlaceItem(context, "부전제3동"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceItem(BuildContext context, String title) {
    return InkWell(
      onTap: () => Navigator.pop(context, title),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: "CookieRun",
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
