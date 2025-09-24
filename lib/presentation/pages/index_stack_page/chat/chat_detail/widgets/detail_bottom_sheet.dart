import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../domain/chat/chat_provider/chat_message_notifier.dart';
import '../../../../../widgets/custom_text_form_field.dart';

class DetailBottomSheet extends ConsumerStatefulWidget {
  final int receiverId; // 현재 대화할 상대방 ID
  final int? roomId;
  final int itemId;

  const DetailBottomSheet({
    required this.receiverId,
    this.roomId,
    required this.itemId,
    super.key,
  });

  @override
  ConsumerState<DetailBottomSheet> createState() => _DetailBottomSheetState();
}

class _DetailBottomSheetState extends ConsumerState<DetailBottomSheet> {
  final TextEditingController _controller = TextEditingController(); // 입력 값 확인
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      await ref.read(chatProvider(widget.roomId).notifier).sendMessage(
        receiverId: widget.receiverId,
        message: base64String,
        itemId: widget.itemId,
        messageType: 'IMAGE',
        images: [base64String],
      );
    }
  }

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
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
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
                if (message.isEmpty) return;

                final receiverId =
                    widget.receiverId; // ChatDetail에서 전달받은 receiverId
                final itemId = widget.itemId;

                await ref
                    .read(chatProvider(widget.roomId).notifier)
                    .sendMessage(
                      receiverId: receiverId,
                      message: message,
                      itemId: itemId,
                    );
                _controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
