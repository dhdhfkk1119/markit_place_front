import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_color.dart';

import '../../../../widgets/snackbar_util.dart';

class ChatDetail extends StatefulWidget {
  final room;

  const ChatDetail({super.key, required this.room});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final List<Map<String, dynamic>> _chatData = [
    {
      'type': 'date_separator', // 날짜 구분선 타입
      'date': '2025년 9월 1일',
    },
    {
      'type': 'message', // 일반 메시지 타입
      'isMe': false, // 상대방 메시지
      'text': '안녕하세요',
      'time': '오후 7:51',
    },
    {
      'type': 'message',
      'isMe': true, // 내 메시지
      'text': '혹시 판매 되었을까요?',
      'time': '오후 7:51',
    },
    {
      'type': 'message',
      'isMe': false,
      'text': '아직 판매 중이에요.',
      'time': '오후 7:55',
    },
    {
      'type': 'transaction', // 특별한 타입 (예: 송금)
      'isMe': true,
      'amount': '550,000원',
      'recipient': 'MP페이',
      'time': '오후 8:02',
    },
    {
      'type': 'message',
      'isMe': true,
      'text': '지금 바로 입금 할게요',
      'time': '오후 8:02',
    },
    {
      'type': 'message',
      'isMe': false,
      'text': '네 알겠습니다',
      'time': '오후 8:03',
    },
    {
      'type': 'message',
      'isMe': false,
      'text': 'MP페이 송금해주시고 만나서 바로 직거래 하도록 해요',
      'time': '오후 8:03',
    },
    {
      'type': 'message',
      'isMe': true,
      'text': '네넵 알겠습니다',
      'time': '오후 8:05',
    }
  ];

  @override
  Widget build(BuildContext context) {
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
              widget.room["name"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    const SizedBox(
                      width: 10,
                    ),
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
            Expanded(
              child: ListView.builder(
                itemCount: _chatData.length,
                itemBuilder: (context, index) {
                  final item = _chatData[index];

                  if (item['type'] == 'date_separator') {
                    return _buildDateSeparator(item['date']);
                  } else if (item['type'] == 'transaction') {
                    return const SizedBox.shrink();
                  } else {
                    final isMe = item['isMe'] as bool;
                    if (isMe) {
                      return _buildMyMessage(context, item);
                    } else {
                      return _buildOtherMessage(context, item);
                    }
                  }
                }, // itemBuilder는 여기서 끝!
              ),
            )
          ],
        ),
      ),
    );
  } // build 메서드는 여기서 끝!

  // --- ⭐ 함수 정의를 build 메서드 밖으로 이동! ---

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

  Widget _buildOtherMessage(
      BuildContext context, Map<String, dynamic> message) {
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
              splashColor: CustomColor.invisible,
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
              child: Text(message['text']),
            ),
          ),
          const SizedBox(width: 8),
          Text(message['time']),
        ],
      ),
    );
  }

  Widget _buildMyMessage(BuildContext context, Map<String, dynamic> message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(message['time']),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(message['text']),
          ),
        ],
      ),
    );
  }
}
