import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/providers/auth_form/SessionNotifier.dart';

import '../../dtos/chat_dto/chat_message_dto.dart';
import '../../models/chat_model/chat_message.dart';
import '../../repositories/chat_repository/chat_repository.dart';

class ChatNotifier extends StateNotifier<List<ChatMessageDto>> {
  final ChatRepository repository;
  final int myId;

  ChatNotifier(this.repository, this.myId) : super([]);

  void connect() {
    repository.connect((json) {
      final model = ChatMessageModel.fromJson(json);
      final dto = ChatMessageDto.fromModel(model, myId);
      state = [...state, dto];
    });
  }

  void sendMessage(int receiverId, String message) {
    repository.sendMessage(receiverId, message);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessageDto>>(
  (ref) {
    final session = ref.watch(sessionProvider);
    final myId = session.user?.id ?? 1;
    return ChatNotifier(ChatRepository(), myId);
  },
);
