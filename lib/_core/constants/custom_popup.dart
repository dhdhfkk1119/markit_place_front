import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';

class CustomPopUp {
  static buildAppBarPopUp(BuildContext context, String userName,
      String productName, int productId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.report, color: Colors.red),
          title: CustomWidget.buildTitle("신고하기", weight: FontWeight.w200),
          onTap: () {
            Navigator.pop(context); // 바텀시트 닫기
            showReportPopUp(context, userName, productName, productId);
          },
        ),
        ListTile(
          leading: const Icon(Icons.close, color: Colors.grey),
          title: const Text("닫기"),
          onTap: () {
            Navigator.pop(context); // 바텀시트 닫기
          },
        ),
      ],
    );
  }

  static showReportPopUp(BuildContext context, String userName,
      String productName, int productId) {
    final TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 터치로 닫히지 않도록
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Center(child: CustomWidget.buildTitle("신고하기")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomWidget.buildTitle(
                    "사용자 이름 : ",
                  ),
                  CustomWidget.buildTitle(
                    "$userName",
                    weight: FontWeight.w200,
                  )
                ],
              ),
              Row(
                children: [
                  CustomWidget.buildTitle(
                    "상품 이름 : ",
                  ),
                  CustomWidget.buildTitle(
                    "$productName",
                    weight: FontWeight.w200,
                  ),
                  CustomWidget.buildTitle(
                    "($productId)",
                    weight: FontWeight.w200,
                  )
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: CustomWidget.buildTitle("신고 사유 :", size: 14),
              ),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "신고 사유를 입력하세요",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 닫기
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                String reason = _reasonController.text;
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("신고 사유를 입력하세요.")),
                  );
                  return;
                }
                // TODO: 서버에 신고 내용 전송 로직 추가
                print(
                    "신고자: $userName, 상품: $productName($productId), 사유: $reason");

                Navigator.pop(context); // 팝업 닫기
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }
}
