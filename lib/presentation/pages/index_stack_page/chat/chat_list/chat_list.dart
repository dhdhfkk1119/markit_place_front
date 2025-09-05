import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/chat/chat_detail/chat_datail.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  int? _roomCount;

  List<Map<String, dynamic>> testMapList = [
    {"id": 1, "name": "익명의 유저", "lastMsg": "혹시 언제쯤 가능하세요?", "isRead": false},
    {"id": 2, "name": "당근 사랑", "lastMsg": "감사합니다~", "isRead": true},
    {"id": 3, "name": "중고 마스터", "lastMsg": "아직 안 팔린건가요?", "isRead": true},
    {"id": 4, "name": "네고 안받음", "lastMsg": "생각보다 상태가 괜찮네요", "isRead": false}
  ];

  List<Map<String, dynamic>> buttonMapList = [
    {"id": 1, "text": "전체"},
    {"id": 2, "text": "판매"},
    {"id": 3, "text": "구매"},
    {"id": 4, "text": "읽지 않은 채팅"}
  ];

  int _selectedButtonId = 1;
  bool _isShowBanner = true;

  @override
  void initState() {
    super.initState();
    _roomCount = testMapList.length;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 30,
              ),
              const Text(
                "채팅 목록",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "${_roomCount ?? 0}",
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
                    buttonMapList[0]["id"], buttonMapList[0]["text"]),
                const SizedBox(width: 15),
                _buildSelectButton(
                    buttonMapList[1]["id"], buttonMapList[1]["text"]),
                const SizedBox(width: 15),
                _buildSelectButton(
                    buttonMapList[2]["id"], buttonMapList[2]["text"]),
                const SizedBox(width: 15),
                _buildSelectButton(
                    buttonMapList[3]["id"], buttonMapList[3]["text"]),
              ],
            ),
          ),
          _isShowBanner
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
                          const SizedBox(
                            width: 5,
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _isShowBanner = false;
                                });
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.purple,
                              ))
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
                itemCount: testMapList.length,
                itemBuilder: (context, index) {
                  final room = testMapList[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 30,
                      height: 30,
                      child: ClipOval(
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          "assets/logo.png",
                          height: 10,
                          width: 10,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      room["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      room["lastMsg"],
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

  Widget _buildSelectButton(int id, String text) {
    return TextButton(
      onPressed: () {
        _selectedButtonId = id;
        setState(() {});
      },
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey[300]!)),
          backgroundColor:
              _selectedButtonId == id ? Colors.black87 : Colors.white,
          minimumSize: const Size(10, 10)),
      child: Text(
        style: TextStyle(
            color: _selectedButtonId == id ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold),
        text,
      ),
    );
  }
}
