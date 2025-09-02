import 'package:flutter/material.dart';

class ProductFiterList extends StatelessWidget {
  const ProductFiterList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Text(
            "필터",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: "CookieRun"),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "초기화",
              style: TextStyle(
                  fontFamily: "CookieRun",
                  color: Colors.grey,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      Text(
        "위치",
        style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 16, fontFamily: "CookieRun"),
      ),
      Text("부산광역시 부산 진구"),
    ]);
  }
}
