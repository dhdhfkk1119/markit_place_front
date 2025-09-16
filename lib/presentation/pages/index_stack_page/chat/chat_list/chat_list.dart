import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/domain/chat/chat_provider/chat_room_notifier.dart';
import 'package:markit_place_front/domain/providers/SessionNotifier.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/chat/chat_detail/chat_datail.dart';

class ChatList extends ConsumerWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomNotifier = ref.watch(chatRoomNotifierProvider);
    if (chatRoomNotifier.chatRooms.isEmpty &&
        !chatRoomNotifier.isLoading &&
        chatRoomNotifier.errorMessage.isEmpty) {
      Future.microtask(
          () => ref.read(chatRoomNotifierProvider).fetchMyChatRooms());
    }

    // 로딩 중 상태 처리
    if (chatRoomNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // 에러 상태 처리
    if (chatRoomNotifier.errorMessage.isNotEmpty) {
      return Center(child: Text('에러 발생: ${chatRoomNotifier.errorMessage}'));
    }

    if (chatRoomNotifier.chatRooms.isEmpty) {
      return const Center(child: Text('채팅방이 없습니다.'));
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 30),
              const Text(
                "채팅 목록",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Text(
                "${chatRoomNotifier.chatRooms.length}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildSelectButton(
                    ref,
                    1,
                    "전체",
                    chatRoomNotifier.selectedButtonId,
                    chatRoomNotifier.setSelectedButtonId),
                const SizedBox(width: 15),
                _buildSelectButton(
                    ref,
                    2,
                    "판매",
                    chatRoomNotifier.selectedButtonId,
                    chatRoomNotifier.setSelectedButtonId),
                const SizedBox(width: 15),
                _buildSelectButton(
                    ref,
                    3,
                    "구매",
                    chatRoomNotifier.selectedButtonId,
                    chatRoomNotifier.setSelectedButtonId),
                const SizedBox(width: 15),
                _buildSelectButton(
                    ref,
                    4,
                    "읽지 않은 채팅",
                    chatRoomNotifier.selectedButtonId,
                    chatRoomNotifier.setSelectedButtonId),
              ],
            ),
          ),
          chatRoomNotifier.isShowBanner
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple[200]!),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.purple[100],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            ("구매 또는 판매시 안전하고 깨끗한 거래 환경을 조성해주세요.\n이를 지키지 않아 발생하는 모든 책임은 이용자에게 있습니다."),
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                              onPressed: () {
                                // 'read()'를 사용하여 메서드 호출
                                ref
                                    .read(chatRoomNotifierProvider)
                                    .toggleBanner(false);
                              },
                              icon: const Icon(Icons.cancel,
                                  color: Colors.purple))
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(height: 0.5, thickness: 0.5);
                },
                itemCount: chatRoomNotifier.chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatRoomNotifier.chatRooms[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 30,
                      height: 30,
                      child: ClipOval(
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          Assets.Images.logo,
                          height: 10,
                          width: 10,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      room.otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      room.lastMessage,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.purple,
                      ),
                    ),
                    onTap: () {
                      print("해당 방의 번호는 ${room.roomId}");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatDetail(room: room)));
                    },
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget _buildSelectButton(WidgetRef ref, int id, String text, int selectedId,
      Function(int) setSelectedId) {
    return TextButton(
      onPressed: () {
        // 'read()'를 사용하여 메서드 호출
        ref.read(chatRoomNotifierProvider).setSelectedButtonId(id);
      },
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey[300]!)),
          backgroundColor: selectedId == id ? Colors.black87 : Colors.white,
          minimumSize: const Size(10, 10)),
      child: Text(
        text,
        style: TextStyle(
            color: selectedId == id ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
