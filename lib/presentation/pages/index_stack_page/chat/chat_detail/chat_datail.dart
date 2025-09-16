import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/domain/chat/chat_dto/chat_message_dto.dart';
import 'package:markit_place_front/domain/chat/chat_provider/chat_detail_notifier.dart';
import 'package:markit_place_front/domain/chat/chat_provider/chat_message_notifier.dart';
import 'package:markit_place_front/domain/providers/SessionNotifier.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/chat/chat_detail/widgets/detail_bottom_sheet.dart';

import '../../../../../domain/chat/chat_dto/chat_room_dto.dart';
import '../../../../widgets/snackbar_util.dart';

class ChatDetail extends ConsumerStatefulWidget {
  final ChatRoomDTO room;

  const ChatDetail({super.key, required this.room});

  @override
  ConsumerState<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends ConsumerState<ChatDetail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final session = ref.read(sessionProvider);
      if (session.user != null) {
        ref
            .read(chatDetailNotifierProvider)
            .fetchMessages(roomId: widget.room.roomId, myId: session.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatDetailNotifier = ref.watch(chatDetailNotifierProvider);

    if (chatDetailNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chatDetailNotifier.errorMessage.isNotEmpty) {
      return Center(child: Text(chatDetailNotifier.errorMessage));
    }
    return Consumer(builder: (context, ref, child) {
      ref.listen(chatProvider(widget.room.roomId), (previous, next) {
        if (next.isNotEmpty && mounted) {
          ref.read(chatDetailNotifierProvider).addNewMessages(next);

          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      });

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room.otherUserName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "보통 10분내 응답",
                style: TextStyle(fontSize: 14, color: Colors.grey[200]!),
              ),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.ellipsis_vertical)),
          ],
          bottom: const PreferredSize(
              preferredSize: Size.zero,
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.black38,
              )),
          backgroundColor: Colors.purple[100],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 상품 정보 영역
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black38))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          "assets/product.jpg",
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("rtx 3080ti 새삥 [미사용]"),
                          Row(children: [
                            Text("550,000원"),
                            Text(
                              "(가격제안불가)",
                              style: TextStyle(color: Colors.grey),
                            )
                          ])
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // 채팅 리스트
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: chatDetailNotifier.messages.length,
                  itemBuilder: (context, index) {
                    final item = chatDetailNotifier.messages[index];

                    if (item.time == 'createdAt') {
                      return _buildDateSeparator(item.content);
                    } else if (item.type == 'transaction') {
                      return const SizedBox.shrink();
                    } else {
                      if (item.isMine) {
                        return _buildMyMessage(context, item);
                      } else {
                        return _buildOtherMessage(context, item);
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
        bottomSheet: DetailBottomSheet(
          receiverId: widget.room.otherUserId,
          roomId: widget.room.roomId,
        ),
      );
    });
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chip(
          label: Text(date),
        ),
      ),
    );
  }

  Widget _buildOtherMessage(BuildContext context, ChatMessageDto message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: const AssetImage("assets/logo.png"),
            child: MaterialButton(
              onPressed: () {
                SnackBarUtil.showSuccess(context, "테스트");
              },
              splashColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(message.content),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMessage(BuildContext context, ChatMessageDto message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(message.content),
          ),
        ],
      ),
    );
  }
}
