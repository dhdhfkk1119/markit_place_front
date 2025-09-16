import 'package:flutter/material.dart';

import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';

class MyProfileEditPage extends StatelessWidget {
  const MyProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 새로운 색상 팔레트 (봄 웜톤)
    const Color primaryColor = Color(0xFFF96666);
    const Color profileAvatarColor = Color(0xFFF5E6E6);
    const Color accentColor = Color(0xFFFFF7F7);
    const Color lightGrey = Color(0xFFFFFFFF);
    const Color secondaryTextColor = Color(0xFFB5A1A1);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle(
          "프로필 수정",
          size: 18,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: '완료' 버튼을 눌렀을 때 프로필 저장 로직 구현
            },
            child: CustomWidget.buildTitle(
              "완료",
              size: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 프로필 이미지 수정 영역
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: profileAvatarColor,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // 닉네임 입력 필드
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(
                  "닉네임",
                  size: 16,
                  weight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: "닉네임을 입력하세요",
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
                      fontFamily: Assets.Fonts.cookieRun,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: accentColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}