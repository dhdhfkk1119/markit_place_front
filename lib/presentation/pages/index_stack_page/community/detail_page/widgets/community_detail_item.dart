import 'package:flutter/material.dart';

import '../../../../../../_core/constants/custom_widget.dart';

class CommunityDetailItem extends StatefulWidget {
  const CommunityDetailItem({super.key});

  @override
  State<CommunityDetailItem> createState() => _CommunityDetailItemState();
}

class _CommunityDetailItemState extends State<CommunityDetailItem> {
  @override
  Widget build(BuildContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfile(),
        const SizedBox(
          height: 16,
        ),
        CustomWidget.buildTitle(
          "상품 상세 정보",
          size: 20,
        ),
        const SizedBox(height: 8),
        const Text(
          "이 상품은 아주 좋은 상품입니다. 상세한 내용은 아래와 같습니다.",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          "조정우 바보 멍청이 똥깨 말미잘 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. 이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
          "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
          "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
          "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
          "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
          "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
          "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다.",
        ),
      ],
    );
  }

  Widget _buildProfile() {
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
                  "assets/default_profile.png",
                  width: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.buildTitle("사용자 이름",
                        size: 16, weight: FontWeight.w500),
                    CustomWidget.buildTitle("연제구 연산제 8동",
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
