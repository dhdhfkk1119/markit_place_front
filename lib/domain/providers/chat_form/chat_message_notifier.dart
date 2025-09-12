import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/providers/auth_form/SessionNotifier.dart';

import '../../dtos/chat_dto/chat_message_dto.dart';
import '../../models/chat_model/chat_message.dart';
import '../../repositories/chat_repository/chat_repository.dart';

class ChatNotifier extends StateNotifier<List<ChatMessageDto>> {
  final ChatRepository repository;
  final int myId;
  final int roomId; // 방 번호도 관리해야 함

  ChatNotifier(this.repository, this.myId, this.roomId) : super([]);

  void connect() {
    repository.connect(roomId, (json) {
      final model = ChatMessageModel.fromJson(json);
      final dto = ChatMessageDto.fromModel(model, myId);
      state = [...state, dto];
    });
  }

  void sendMessage(int receiverId, String message) {
    repository.sendMessage(roomId, receiverId, message);
  }
}

// Provider 만들 때 roomId도 같이 주입
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, List<ChatMessageDto>, int>(
  (ref, roomId) {
    final session = ref.watch(sessionProvider);
    final myId = session.user?.id ?? 1;
    return ChatNotifier(ChatRepository(), myId, roomId);
  },
);
