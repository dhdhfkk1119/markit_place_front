import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/assets.dart';
import '../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../domain/chat/chat_provider/chat_room_notifier.dart';
import '../../../../../domain/members/providers/OtherProfileNotifier.dart';
import '../../../../../domain/members/providers/profile_provider.dart';
import '../chat_detail/chat_datail.dart';

class ChatList extends ConsumerStatefulWidget {
  const ChatList({super.key});

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때만 호출
    Future.microtask(() {
      ref.read(chatRoomNotifierProvider).fetchMyChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomNotifier = ref.watch(chatRoomNotifierProvider);

    if (chatRoomNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
    final filteredRooms = chatRoomNotifier.selectedButtonId == 4
        ? chatRoomNotifier.chatRooms
            .where((room) => room.unreadMessageCount! > 0)
            .toList()
        : chatRoomNotifier.chatRooms;

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
                                ref
                                    .read(chatRoomNotifierProvider)
                                    .toggleBanner(false);
                                // 방 목록을 다시 불러옴
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
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  return Consumer(
                    builder: (context, ref, _) {
                      final profileState =
                          ref.watch(userProfileProvider(room.otherUserId));

                      return ListTile(
                        leading: SizedBox(
                          width: 30,
                          height: 30,
                          child: ClipOval(
                            child: profileState.when(
                              data: (user) {
                                if (user?.profileImageBase64 != null) {
                                  final bytes =
                                      base64Decode(user!.profileImageBase64!);
                                  return Image.memory(bytes, fit: BoxFit.cover);
                                } else {
                                  return Image.asset(
                                    Assets.Images.logo,
                                    fit: BoxFit.cover,
                                  );
                                }
                              },
                              loading: () => const CircularProgressIndicator(
                                  strokeWidth: 2),
                              error: (e, _) => Image.asset(
                                Assets.Images.logo,
                                fit: BoxFit.cover,
                              ),
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
                            color: room.unreadMessageCount == 0
                                ? Colors.white
                                : Colors.purple,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatDetail(room: room)),
                          );
                        },
                      );
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
