import 'package:flutter/material.dart';
import '../../../../../widgets/WriteButton.dart';
import 'community_filter_list.dart';
import 'community_list_item.dart';

class CommunityListBody extends StatelessWidget {
  final bool isFilterVisible;
  final VoidCallback onWritePressed;

  const CommunityListBody({
    super.key,
    required this.isFilterVisible,
    required this.onWritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isFilterVisible
                      ? const SizedBox(
                          key: ValueKey(true),
                          width: 155,
                          child: CommunityFilterList(),
                        )
                      : const SizedBox.shrink(key: ValueKey(false)),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: 10,
                    itemBuilder: (context, index) =>
                        CommunityListItem(isFilterVisible),
                    separatorBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child:
                          Divider(height: 1, thickness: 1, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          WriteButton(
            onTap: onWritePressed,
            title: "글쓰기",
          ),
        ],
      ),
    );
  }
}
