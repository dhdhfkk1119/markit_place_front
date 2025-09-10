import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/mypage/my_profile_page/widgets/my_profile_body.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyProfileBody(),
    );
  }
}
