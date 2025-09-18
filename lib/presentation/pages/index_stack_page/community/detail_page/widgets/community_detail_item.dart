import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/constants/assets.dart';
import 'package:markit_place_front/domain/community/community_dto/community_detail_dto.dart';
import 'package:markit_place_front/domain/community/community_provider/community_detail_notifier.dart';

import '../../../../../../_core/constants/custom_widget.dart';

class CommunityDetailItem extends ConsumerStatefulWidget {
  final int postId;
  const CommunityDetailItem({required this.postId, super.key});

  @override
  ConsumerState<CommunityDetailItem> createState() =>
      _CommunityDetailItemState();
}

class _CommunityDetailItemState extends ConsumerState<CommunityDetailItem> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(communityDetailProvider(widget.postId).notifier)
          .getCommunityDetailInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(communityDetailProvider(widget.postId));

    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null) {
      return Center(child: Text('오류발생: ${notifier.errorMessage}'));
    }

    if (notifier.communityDetail == null) {
      // 아직 데이터 안 온 상태
      return const Center(child: Text("데이터를 불러오는 중입니다..."));
    }

    final post = notifier.communityDetail!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfile(post),
        const SizedBox(
          height: 16,
        ),
        CustomWidget.buildTitle(
          "${post.title}",
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          "${post.title}",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          "${post.content}",
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProfile(CommunityDetailDto dto) {
    return InkWell(
      child: Row(
        // 자식 위젯들을 양 끝으로 정렬
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. 프로필 이미지와 사용자 정보를 하나의 Row로 묶습니다.
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  Assets.Images.defaultProfile,
                  width: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.buildTitle("${dto.writerName}",
                        size: 16, weight: FontWeight.w500),
                    CustomWidget.buildTitle("${dto.location}",
                        size: 12, color: Colors.grey, weight: FontWeight.w200),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
