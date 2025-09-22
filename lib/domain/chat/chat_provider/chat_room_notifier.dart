import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_dto/chat_message_dto.dart';
import '../chat_dto/chat_room_dto.dart';
import '../chat_model/chat_message.dart';
import '../chat_repository/chat_repository.dart';
import '../chat_repository/chat_room_repository.dart';

class ChatRoomNotifier extends ChangeNotifier {
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  final ChatRepository _chatRepository = ChatRepository();

  List<ChatRoomDTO> chatRooms = [];

  bool isLoading = false;
  String errorMessage = '';
  int _selectedButtonId = 1;
  bool _isShowBanner = true;

  int get selectedButtonId => _selectedButtonId;
  bool get isShowBanner => _isShowBanner;

  void setSelectedButtonId(int id) {
    _selectedButtonId = id;
    notifyListeners();
  }

  void toggleBanner(bool isVisible) {
    _isShowBanner = isVisible;
    notifyListeners();
  }

  Future<void> fetchMyChatRooms() async {
    isLoading = true;
    notifyListeners();
    try {
      chatRooms = await _chatRoomRepository.getMyRoom();
      errorMessage = '';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required int? roomId,
    required int userId,
    required int receiverId,
    required String message,
    required int itemId,
  }) async {
    await _chatRepository.sendMessage(
      roomId: roomId,
      receiverId: receiverId,
      message: message,
      itemId: itemId,
    );

    await fetchMyChatRooms();
  }

  // 메세지를 받으면 새로 업데이트
  Future<void> updateLastMessage(ChatMessageDto message, int roomId) async {
    final index = chatRooms.indexWhere((room) => room.roomId == roomId);
    if (index != -1) {
      final updatedRoom = chatRooms[index].copyWith(
        lastMessage: message.content,
      );

      // 목록에서 해당 채팅방을 가장 위로 이동시킵니다.
      chatRooms.removeAt(index);
      chatRooms.insert(0, updatedRoom);

      notifyListeners();
    } else {
      // 만약 채팅방이 없다면, 새로운 방을 생성해야 할 수도 있습니다.
      // 이 로직은 백엔드 응답에 따라 달라질 수 있으므로, 필요시 추가 구현합니다.
      fetchMyChatRooms();
    }
  }
}

final chatRoomNotifierProvider = ChangeNotifierProvider((ref) {
  return ChatRoomNotifier();
});
