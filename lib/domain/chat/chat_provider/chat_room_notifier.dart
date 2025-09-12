import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/chat/chat_dto/chat_room_dto.dart';
import 'package:markit_place_front/domain/chat/chat_repository/chat_repository.dart';
import 'package:markit_place_front/domain/chat/chat_repository/chat_room_repository.dart';

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

  Future<void> fetchMyChatRooms({required int userId}) async {
    isLoading = true;
    notifyListeners();
    try {
      chatRooms = await _chatRoomRepository.getMyRoom(userId: userId);
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
  }) async {
    await _chatRepository.sendMessage(
      roomId: roomId,
      receiverId: receiverId,
      message: message,
    );
    await fetchMyChatRooms(userId: userId);
  }
}

final chatRoomNotifierProvider = ChangeNotifierProvider((ref) {
  return ChatRoomNotifier();
});
