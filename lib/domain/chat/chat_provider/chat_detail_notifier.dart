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
      // 1. 메시지 목록 가져오기 (메인 로직)
      messages = await repository.getMyRoomMessage(roomId: roomId, myId: myId);
      print("[Notifier] 메시지 목록 fetch 완료, messages.length=${messages.length}");

      // 2. 읽음 처리는 별도의 try/catch로 감싸서 메인 로직에 영향이 없도록 합니다.
      try {
        await repository.markMessagesAsRead(roomId: roomId, myId: myId);
        print("[Notifier] 메시지 읽음 처리 완료");
      } catch (e) {
        print("[Notifier] 경고: 읽음 처리 실패. $e");
        // 메시지 로드는 성공했으므로 에러 메시지를 덮어쓰지 않습니다.
      }

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
    final myId = authState.user?.memberId;

    final isMine = newMessages.senderId == myId;

    if (isMine) {
      newMessages = newMessages.copyWith(
        isMine: true,
        isRead: false,
      );
    } else {
      newMessages = newMessages.copyWith(isMine: false);
    }

    // 메시지 목록에 추가
    final newMessagesList = List<ChatMessageDto>.from(messages)
      ..add(newMessages);
    messages = newMessagesList;
    notifyListeners();
  }
}

final chatDetailNotifierProvider = ChangeNotifierProvider((ref) {
  return ChatDetailNotifier();
});
