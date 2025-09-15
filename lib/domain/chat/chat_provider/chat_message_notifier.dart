import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/chat/chat_dto/chat_message_dto.dart';
import 'package:markit_place_front/domain/chat/chat_model/chat_message.dart';
import 'package:markit_place_front/domain/chat/chat_repository/chat_repository.dart';
import 'package:markit_place_front/domain/providers/auth_form/SessionNotifier.dart';

class ChatNotifier extends StateNotifier<List<ChatMessageDto>> {
  final ChatRepository repository;
  final int myId;
  int? _roomId;

  ChatNotifier(this.repository, this.myId) : super([]);

  // RoomId를 설정하는 메서드
  void setRoomId(int? roomId) {
    if (roomId != null && _roomId != roomId) {
      _roomId = roomId;
      print("[ChatNotifier] Room ID updated to $_roomId");
    }
  }

  void connect() {
    // roomId가 null이면 연결하지 않습니다. 첫 메시지를 보내기 전에는 연결이 불필요합니다.
    if (_roomId == null) return;

    repository.connect(
      roomId: _roomId!, // connect는 roomId가 null이 아니어야 하므로 !를 사용
      onMessageReceived: (json) {
        final model = ChatMessageModel.fromJson(json);
        final dto = ChatMessageDto.fromModel(model, myId);
        state = [dto];
      },
    );
  }

  // 이제 sendMessage 메서드가 roomId를 필수 인자로 받도록 변경
  void sendMessage({required int receiverId, required String message}) async {
    // 첫 메시지 전송 시에는 roomId가 null입니다.
    // 이 경우 ChatRepository가 방 생성 및 메시지 전송을 모두 처리합니다.

    // ChatRepository의 sendMessage를 호출할 때 roomId를 함께 전달합니다.
    repository.sendMessage(
      roomId: _roomId, // roomId가 null일 수 있습니다.
      receiverId: receiverId,
      message: message,
    );
  }

  // 방이 생성되거나 기존 방 ID를 받아왔을 때, Notifier의 상태를 업데이트하는 메서드
  void onRoomIdCreated(int newRoomId) {
    _roomId = newRoomId;
    connect();
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, List<ChatMessageDto>, int?>(
  (ref, roomId) {
    final session = ref.watch(sessionProvider);
    final myId = session.user?.id ?? 1;
    final notifier = ChatNotifier(ChatRepository(), myId);

    // 만약 roomId가 있다면 초기화 시 바로 설정
    if (roomId != null) {
      notifier.setRoomId(roomId);
      notifier.connect();
    }

    return notifier;
  },
);
