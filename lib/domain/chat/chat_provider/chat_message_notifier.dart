import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_dto/chat_message_dto.dart';
import '../chat_model/chat_message.dart';
import '../chat_repository/chat_detail_repository.dart';
import 'chat_room_notifier.dart';
import '../chat_repository/chat_repository.dart';
// import '../../providers/SessionNotifier.dart'; // 수정: SessionNotifier import 제거
import '../../members/providers/member_auth_provider.dart'; // 수정: AuthNotifier import 추가

class ChatNotifier extends StateNotifier<ChatMessageDto?> {
  final ChatRepository repository;
  final ChatDetailRepository? chatDetailRepository;
  final int myId; // 로그인된 사용자의 ID (null이 아님을 가정)
  int? _roomId;
  final Function(ChatMessageModel) onNewMessage;

  ChatNotifier(this.repository, this.myId,
      {this.chatDetailRepository, required this.onNewMessage})
      : super(null);

  void setRoomId(int? roomId) {
    if (roomId != null && _roomId != roomId) {
      _roomId = roomId;
      print("[ChatNotifier] Room ID updated to $_roomId");
      // RoomId가 설정되면 바로 연결 시도 (만약 connect()가 중복 호출되어도 안전하다면)
      // 또는 connect()는 외부에서 명시적으로 호출하도록 할 수도 있음.
      // 현재 chatProvider에서는 roomId 설정 후 connect를 호출하므로 여기서 중복 호출은 피할 수 있음.
    }
  }

  void connect() {
    if (_roomId == null) {
      print("[ChatNotifier] Connect skipped: Room ID is null.");
      return;
    }
    if (myId == 0) {
      // 혹은 다른 유효하지 않은 ID 값으로 체크
      print(
          "[ChatNotifier] Connect skipped: Invalid user ID (myId is $myId). User might not be properly authenticated.");
      return;
    }

    print(
        "[ChatNotifier] Attempting to connect to room: $_roomId with myId: $myId");
    repository.connect(
      roomId: _roomId!,
      onMessageReceived: (json) {
        final model = ChatMessageModel.fromJson(json);
        // fromModel 호출 시 myId 전달
        final dto = ChatMessageDto.fromModel(model, myId);
        state = dto;
        onNewMessage(model);
      },
    );
  }

  Future<int> sendMessage({
    required int receiverId,
    required String message,
    required int itemId,
    String? messageType,
    List<String>? images,
  }) async {
    final type = messageType ?? 'TEXT';

    if (myId == 0) {
      print(
          "[ChatNotifier] sendMessage skipped: Invalid user ID (myId is $myId).");
      if (_roomId == null) return -1; // 임시 처리
      return _roomId!; // 혹은 현재 roomId 반환
    }
    print(
        "[ChatNotifier] sendMessage called. Current _roomId: $_roomId, receiverId: $receiverId, itemId: $itemId, myId: $myId");
    final int newRoomId = await repository.sendMessage(
      roomId: _roomId,
      receiverId: receiverId,
      message: message,
      itemId: itemId,
      messageType: type,
      images: images,
    );
    print(
        "[ChatNotifier] sendMessage: newRoomId received from repository: $newRoomId");

    if (_roomId == null || _roomId != newRoomId) {
      print(
          "[ChatNotifier] sendMessage: Updating _roomId from $_roomId to $newRoomId and reconnecting.");
      setRoomId(newRoomId);
      connect();
    }
    return newRoomId;
  }

  void onRoomIdCreated(int newRoomId) {
    _roomId = newRoomId;
    connect();
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatMessageDto?, int?>(
  (ref, roomId) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.user == null) {
      const int invalidMyId = 0; // 혹은 -1
      final chatRoomNotifier = ref.read(chatRoomNotifierProvider);
      final notifier = ChatNotifier(
        ChatRepository(),
        invalidMyId, // 유효하지 않은 ID 전달
        onNewMessage: (messageModel) {
          // myId가 유효하지 않으면 메시지 처리가 이상해질 수 있음
          final messageDto =
              ChatMessageDto.fromModel(messageModel, invalidMyId);
          chatRoomNotifier.updateLastMessage(messageDto, messageModel.roomId);
        },
      );
      if (roomId != null) {
        notifier.setRoomId(roomId);
        notifier.connect(); // roomId 설정 후 연결 시도
      }
      return notifier;
    }

    // authState.user가 null이 아님을 가정하고 memberId를 가져옵니다.
    final myId = authState.user!.memberId;
    final chatRoomNotifier = ref.read(chatRoomNotifierProvider);

    final notifier = ChatNotifier(
      ChatRepository(),
      myId,
      onNewMessage: (messageModel) {
        final messageDto = ChatMessageDto.fromModel(messageModel, myId);
        chatRoomNotifier.updateLastMessage(messageDto, messageModel.roomId);
      },
    );

    if (roomId != null) {
      notifier.setRoomId(roomId);
      notifier.connect(); // roomId 설정 후 연결 시도
    }

    return notifier;
  },
);
