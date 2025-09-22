import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_dto/chat_message_dto.dart';
import '../chat_model/chat_message.dart';
import 'chat_room_notifier.dart';
import '../chat_repository/chat_repository.dart';
// import '../../providers/SessionNotifier.dart'; // 수정: SessionNotifier import 제거
import '../../members/providers/member_auth_provider.dart'; // 수정: AuthNotifier import 추가

class ChatNotifier extends StateNotifier<ChatMessageDto?> {
  final ChatRepository repository;
  final int myId; // 로그인된 사용자의 ID (null이 아님을 가정)
  int? _roomId;
  final Function(ChatMessageModel) onNewMessage;

  ChatNotifier(this.repository, this.myId, {required this.onNewMessage})
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
  }) async {
    if (myId == 0) {
      // 혹은 다른 유효하지 않은 ID 값으로 체크
      print(
          "[ChatNotifier] sendMessage skipped: Invalid user ID (myId is $myId).");
      // 적절한 에러를 반환하거나 예외를 발생시킬 수 있습니다.
      // 예를 들어, return -1; 또는 throw Exception("Cannot send message: User not properly authenticated.");
      // 현재는 기존처럼 roomId를 반환해야 하므로, 이 부분을 어떻게 처리할지 결정 필요.
      // 임시로, roomId가 null일 경우 문제가 될 수 있으므로, -1을 반환하도록 처리 (API 계약에 따라 변경 필요)
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
      // repository.sendMessage에도 myId (senderId)가 필요하다면 전달해야 함. 현재 API 명세에는 없음.
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

    // 사용자의 의견에 따라, authState.user가 null인 경우는
    // 중복 로그인으로 튕겼을 때와 같은 예외적인 상황으로 간주합니다.
    // 이 경우 채팅 기능을 사용하는 것이 적절하지 않을 수 있습니다.
    // 따라서 user가 null이면 ChatNotifier를 생성하지 않거나,
    // 생성하더라도 기능이 제한된 Notifier를 반환하는 것이 안전합니다.
    // 여기서는 null일 경우를 대비해 memberId에 `!`를 사용하고,
    // 만약 이것이 문제가 된다면 (런타임 에러 발생), 이 부분의 로직을 재검토해야 합니다.
    if (authState.user == null) {
      // 이 시점에서 ChatNotifier를 요구하는 것은 로직상 문제가 있을 수 있음.
      // 예를 들어, 로그인 화면으로 리디렉션 중이거나, 채팅 화면에 접근하면 안 되는 상태일 수 있음.
      print(
          "[chatProvider] Error: User is not authenticated. Cannot create ChatNotifier effectively. authState.status: ${authState.status}");
      // 안전하게 가려면 여기서 ChatNotifier를 생성하지 않거나,
      // myId를 특수 값(예: 0 또는 -1)으로 설정하고 ChatNotifier 내부에서 해당 ID를 처리하도록 합니다.
      // ChatNotifier는 myId를 non-nullable int로 받으므로, 0을 임시로 사용합니다.
      // 이 부분은 앱의 전체적인 인증 흐름과 에러 처리 정책에 따라 결정되어야 합니다.
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
