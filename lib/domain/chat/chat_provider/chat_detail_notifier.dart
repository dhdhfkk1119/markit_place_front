import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_dto/chat_message_dto.dart';
import '../chat_repository/chat_detail_repository.dart';
import '../../members/providers/member_auth_provider.dart';
import '../chat_repository/chat_room_repository.dart';

class ChatDetailNotifier extends ChangeNotifier {
  final ChatDetailRepository repository = ChatDetailRepository();
  final ChatRoomRepository roomRepository = ChatRoomRepository();

  List<ChatMessageDto> messages = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchMessages({
    required int roomId,
    required int myId,
  }) async {
    print("[Notifier] enterChatRoom 호출: roomId=$roomId, myId=$myId");

    isLoading = true;
    notifyListeners();

    try {
      // 1. 읽음 처리 API 호출 (메시지를 가져오기 전에 먼저 처리)
      await repository.markMessagesAsRead(roomId: roomId, myId: myId);
      print("[Notifier] 메시지 읽음 처리 완료");

      // 2. 메시지 목록 가져오기
      messages = await repository.getMyRoomMessage(roomId: roomId, myId: myId);
      print("[Notifier] 메시지 목록 fetch 완료, messages.length=${messages.length}");

      errorMessage = '';
    } catch (e) {
      print("[Notifier] enterChatRoom 에러: $e");
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
