import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/members/providers/member_auth_provider.dart';
import 'widgets/my_profile_body.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  final int userRating;

  const MyProfilePage(this.userRating, {super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authNotifierProvider);
    final user = authUser.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: MyProfileBody(
        user: user,
        userRating: widget.userRating,
      ),
    );
  }
}
