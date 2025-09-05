import 'package:flutter/material.dart';

class DetailItem extends StatefulWidget {
  const DetailItem({super.key});

  @override
  State<DetailItem> createState() => _DetailItemState();
}

class _DetailItemState extends State<DetailItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildProfileInfo(), _buildRating()],
          ),
          _buildDriver(),
          _buildTitle("제목을 가져오는 칸입니다", size: 18),
          _buildTitle("500,000원", size: 18),
          _buildTitle("디지털 기기",
              size: 14,
              t: TextDecoration.underline,
              weight: FontWeight.w200,
              color: Colors.grey),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: _buildTitle(
                "조텍 게이밍 RTX 4080 SUPER Trinity Black Edition 16GB "
                "그래픽 카드입니다 박스 포함이고, 내부 구성품 모두 들어있습니다. "
                "24년 6월 제조로 무상 AS는 3년입니다. 기존 4070 사용자로 4080 까지는 필요없을듯  "
                "하여 보관만하고있어 내놓습니다. 많이 사용하지않은 거의 새제품입니다.조텍 게이밍 RTX 4080 SUPER Trinity Black Edition 16GB "
                "그래픽 카드입니다 박스 포함이고, 내부 구성품 모두 들어있습니다. "
                "24년 6월 제조로 무상 AS는 3년입니다. 기존 4070 사용자로 4080 까지는 필요없을듯  "
                "하여 보관만하고있어 내놓습니다. 많이 사용하지않은 거의 새제품입니다.조텍 게이밍 RTX 4080 SUPER Trinity Black Edition 16GB "
                "그래픽 카드입니다 박스 포함이고, 내부 구성품 모두 들어있습니다. "
                "24년 6월 제조로 무상 AS는 3년입니다. 기존 4070 사용자로 4080 까지는 필요없을듯  "
                "하여 보관만하고있어 내놓습니다. 많이 사용하지않은 거의 새제품입니다."),
          ),
        ],
      ),
    );
  }

  // 프로필 정보
  Widget _buildProfileInfo() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ClipRRect(
            child: Image.asset(
              "assets/default_profile.png",
              width: 50,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("조정우"),
            _buildTitle("범천동", size: 12, color: Colors.grey),
          ],
        )
      ],
    );
  }

  _buildProductContent() {}

  // 구분선
  Widget _buildDriver() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey,
      ),
    );
  }

  // 해당 유저의 평점을 나타낸다
  Widget _buildRating() {
    return Column(
      children: [
        _buildTitle("4.7", color: Colors.blue, size: 18),
        InkWell(
            onTap: () {},
            child: _buildTitle('평점이란',
                size: 12, color: Colors.grey, t: TextDecoration.underline))
      ],
    );
  }

  // 텍스트 처리
  Widget _buildTitle(String title,
      {Color? color, FontWeight? weight, double? size, TextDecoration? t}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: size ?? 14,
        fontFamily: "CookieRun",
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? Colors.black,
        decoration: t ?? null,
      ),
    );
  }
}
