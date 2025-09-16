import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/chat/chat_list/chat_list.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/list_page/community_list_page.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/mypage/main_profile/my_page.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/nearscreen/near_page.dart';

import 'product/list_page/product_list_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 새로운 색상 팔레트 (봄 웜톤)
    const Color primaryColor = Color(0xFFF96666); // 코랄 핑크

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ProductListPage(),
          CommunityListPage(),
          NearPage(),
          ChatList(),
          MyPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: primaryColor, // 코랄 핑크
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                label: '상품', icon: Icon(CupertinoIcons.cart)),
            BottomNavigationBarItem(
                label: '커뮤니티', icon: Icon(CupertinoIcons.square_on_circle)),
            BottomNavigationBarItem(
                label: '주변위치', icon: Icon(Icons.place)),
            BottomNavigationBarItem(
                label: '채팅', icon: Icon(CupertinoIcons.chat_bubble_text_fill)),
            BottomNavigationBarItem(
                label: '나의 MP', icon: Icon(CupertinoIcons.profile_circled))
          ]),
    );
  }
}