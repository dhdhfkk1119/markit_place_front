import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/providers/chat_form/chat_message_notifier.dart';
import 'package:markit_place_front/presentation/widgets/custom_text_form_field.dart';

class DetailBottomSheet extends ConsumerStatefulWidget {
  final int receiverId; // 현재 대화할 상대방 ID

  const DetailBottomSheet({
    required this.receiverId,
    super.key,
  });

  @override
  ConsumerState<DetailBottomSheet> createState() => _DetailBottomSheetState();
}

class _DetailBottomSheetState extends ConsumerState<DetailBottomSheet> {
  final TextEditingController _controller = TextEditingController(); // 입력 값 확인

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.heart),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "메시지를 입력하세요...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
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
              icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
              onPressed: () async {
                final message = _controller.text.trim();
                if (message.isEmpty) {
                  print("[Frontend Log] Message is empty. Aborting send.");
                  return;
                }

                // --- 여기부터 로그를 추가하세요 ---
                print(
                    "[Frontend Log] Send button pressed. Message: '$message'");

                final tempRoomId = 1; // 임시로 0을 보냅니다.
                final receiverId = widget.receiverId;

                print("[Frontend Log] Preparing to send STOMP message.");
                print(
                    "[Frontend Log] Temp Room ID: $tempRoomId, Receiver ID: $receiverId");

                // --- STOMP 메시지 전송 로직 ---
                ref
                    .read(chatProvider(tempRoomId).notifier)
                    .sendMessage(receiverId, message);

                _controller.clear();
                print(
                    "[Frontend Log] Message sent via STOMP. Text field cleared.");
              },
            ),
          ],
        ),
      ),
    );
    ;
  }
}
