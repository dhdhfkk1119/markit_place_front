import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../domain/chat/chat_provider/chat_message_notifier.dart';
import '../../../../../../domain/chat/chat_provider/chat_room_notifier.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../../domain/product/dtos/product_detail_dto.dart';
import '../../../../../../domain/product/providers/product_detail_notifier.dart';
import '../../../../../widgets/custom_text_form_field.dart';

class DetailBottomSheet extends ConsumerStatefulWidget {
  final int receiverId; // 현재 대화할 상대방 ID
  final int itemId;

  const DetailBottomSheet({
    required this.receiverId,
    required this.itemId,
    super.key,
  });

  @override
  ConsumerState<DetailBottomSheet> createState() => _DetailBottomSheetState();
}

class _DetailBottomSheetState extends ConsumerState<DetailBottomSheet> {
  final TextEditingController _controller = TextEditingController(); // 입력 값 확인

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authNotifierProvider);
    final item = ref.read(productDetailProvider(widget.itemId));

    ProductDetailDto dto = item.value!;
    if (auth.user?.memberId == dto.sellerId) {}

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            item.when(
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
                    await ref
                        .read(productDetailProvider(widget.itemId).notifier)
                        .toggleFavorite(widget.itemId);

                    ref.invalidate(productDetailProvider(widget.itemId));
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => IconButton(
                onPressed: null,
                icon: const Icon(CupertinoIcons.heart),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextFormField(
                controller: _controller,
                enabled: auth.user?.memberId != dto.sellerId,
                decoration: InputDecoration(
                  hintText: auth.user?.memberId == dto.sellerId
                      ? "자신의 상품에는 메세지를 보낼수없습니다"
                      : "메세지를 입력하세요",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: auth.user?.memberId == dto.sellerId
                      ? Colors.grey[300]
                      : Colors.grey[200],
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: auth.user?.memberId != dto.sellerId
                  ? const Icon(Icons.send, color: Colors.deepPurpleAccent)
                  : const Icon(Icons.cancel_schedule_send,
                      color: Colors.deepPurpleAccent),
              onPressed: auth.user?.memberId == dto.sellerId
                  ? null
                  : () async {
                      print("해당 상품의 번호는 ${widget.itemId}");

                      final message = _controller.text.trim();
                      if (message.isEmpty) {
                        return;
                      }

                      // receiverId는 widget.receiverId로 올바르게 전달받고 있습니다.
                      final receiverId = widget.receiverId;
                      final itemId = widget.itemId;

                      // sendMessage 호출 (새로운 방이 생성될 경우 roomId를 반환받음)
                      final chatNotifier = ref.read(chatProvider(null)
                          .notifier); // roomId가 없을 수도 있으므로 null 전달
                      await chatNotifier.sendMessage(
                        receiverId: receiverId,
                        message: message,
                        itemId: itemId,
                      );

                      // 메시지 전송 후, ChatRoomNotifier를 통해 채팅방 목록을 새로고침합니다.
                      // 이렇게 하면 새로운 방이 생성되었을 때 리스트가 업데이트됩니다.
                      await ref
                          .read(chatRoomNotifierProvider)
                          .fetchMyChatRooms();

                      _controller.clear();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
