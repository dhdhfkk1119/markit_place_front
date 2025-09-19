import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_dto/chat_message_dto.dart';
import '../chat_repository/chat_detail_repository.dart';
import '../../members/providers/member_auth_provider.dart';

class ChatDetailNotifier extends ChangeNotifier {
  final ChatDetailRepository repository = ChatDetailRepository();

  List<ChatMessageDto> messages = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchMessages({
    required int roomId,
    required int myId,
  }) async {
    print("[Notifier] fetchMessages 호출: roomId=$roomId, myId=$myId");

    isLoading = true;
    notifyListeners();

    try {
      messages = await repository.getMyRoomMessage(roomId: roomId, myId: myId);
      print("[Notifier] fetchMessages 완료, messages.length=${messages.length}");
      errorMessage = '';
    } catch (e) {
      print("[Notifier] fetchMessages 에러: $e");
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addNewMessages(ChatMessageDto newMessages, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);

    // 현재 사용자의 ID를 가져와서 isMine 속성을 업데이트
    if (authState.user != null) {
      newMessages = newMessages.copyWith(
          isMine: newMessages.senderId == authState.user!.memberId);
    }

    final newMessagesList = List<ChatMessageDto>.from(messages)
      ..add(newMessages);
    messages = newMessagesList;
    notifyListeners();
  }
}

final chatDetailNotifierProvider = ChangeNotifierProvider((ref) {
  return ChatDetailNotifier();
});
