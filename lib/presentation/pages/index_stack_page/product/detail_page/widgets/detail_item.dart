import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/assets.dart';

import '../../../../../../_core/constants/custom_widget.dart';

class DetailItem extends StatefulWidget {
  const DetailItem({super.key});

  @override
  State<DetailItem> createState() => _DetailItemState();
}

class _DetailItemState extends State<DetailItem> {
  @override
  Widget build(BuildContext) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfile(),
          _buildDivider(),
          CustomWidget.buildTitle(
            "상품 상세 정보",
            size: 20,
          ),
          CustomWidget.buildTitle(
            "50,000원",
            size: 20,
          ),
          CustomWidget.buildTitle(
            "카테고리",
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          const Text(
            "이 상품은 아주 좋은 상품입니다. 상세한 내용은 아래와 같습니다.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. 이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
            "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
            "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다. "
            "여기에 스크롤될 만큼 많은 내용이 들어갑니다. 스크롤을 내리면 이 텍스트가 위로 올라가고, 스크롤 가능한 모든 내용이 나타납니다. "
            "이 부분은 스크롤 기능을 확인하기 위한 더미 텍스트입니다.",
          ),
          const SizedBox(height: 200),
          const Text("스크롤 끝"),
        ],
      ),
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
                  Assets.Images.defaultProfile,
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

          // 2. 점수 Column을 오른쪽 끝으로 보냅니다.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Column 내부 텍스트를 오른쪽 정렬
            children: [
              CustomWidget.buildTitle("4.5", size: 16, weight: FontWeight.w500),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return _buildBottomPopUp(context);
                    },
                  );
                },
                child: CustomWidget.buildTitle("평균점수",
                    size: 12,
                    weight: FontWeight.w200,
                    color: Colors.grey,
                    decoration: TextDecoration.underline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Divider(
        height: 1, // 선의 높이
        thickness: 1, // 선의 두께
        color: Colors.grey, // 선의 색상
      ),
    );
  }

  // 바텀 팝업에 대한 내용을 나태내는 함수
  Widget _buildBottomPopUp(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20),
              child: CustomWidget.buildTitle("평균 점수 란?"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomWidget.buildTitle(
                  "당신이 사용자로부터 상품을 판매하고 받은 리뷰 점수를 바탕으로 통계를 내린 매너 지표입니다",
                  weight: FontWeight.w100,
                  color: Colors.black54),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: CustomWidget.buildTitle("확인",
                      size: 16, weight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
