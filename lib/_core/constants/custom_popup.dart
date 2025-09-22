import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/members/providers/member_auth_provider.dart';
import '../../domain/product/providers/product_detail_notifier.dart';
import '../../domain/product/providers/product_list_notifier.dart';
import '../../presentation/pages/index_stack_page/main_screen.dart';
import '../../presentation/pages/index_stack_page/product/list_page/product_list_page.dart';
import '../../presentation/pages/index_stack_page/product/write_page/product_write_page.dart';
import 'custom_widget.dart';

class CustomPopUp {
  static buildAppUpdatePop(BuildContext context, String? title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.update, color: Colors.deepPurpleAccent),
          title: CustomWidget.buildTitle("$title", weight: FontWeight.w200),
          onTap: () {
            Navigator.pop(context); // 바텀시트 닫기
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

  static buildAppBarPopUp(
    BuildContext context,
    String userName,
    String productName,
    int productId, {
    String? title,
    WidgetRef? ref,
  }) {
    if (ref == null) return const SizedBox.shrink();

    final notifier = ref.read(productListProvider.notifier);

    // AsyncNotifier로 바뀐 경우
    final productAsyncValue = ref.watch(productDetailProvider(productId));

    return productAsyncValue.when(
      data: (model) {
        // 로그인한 유저 정보
        final authState = ref.watch(authNotifierProvider);
        final currentUser = authState.user;
        final isOwner = model?.sellerId == currentUser?.memberId;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: CustomWidget.buildTitle("신고하기", weight: FontWeight.w200),
              onTap: () {
                Navigator.pop(context);
                showReportPopUp(context, userName, productName, productId);
              },
            ),
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: CustomWidget.buildTitle("삭제하기", weight: FontWeight.w200),
                onTap: () async {
                  Navigator.pop(context);

                  await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("삭제 확인"),
                      content: const Text("정말로 이 상품을 삭제하시겠습니까?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("취소"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await notifier.deleteProduct(productId);
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.pushReplacementNamed(
                                context, "/product/list");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("삭제"),
                        )
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.update, color: Colors.deepPurpleAccent),
                title: CustomWidget.buildTitle("수정하기", weight: FontWeight.w200),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductWritePage(model: model),
                    ),
                  );
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text("닫기"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("상품 정보를 불러올 수 없습니다.")),
    );
  }

  static showReportPopUp(BuildContext context, String userName,
      String productName, int productId) {
    final TextEditingController reasonController = TextEditingController();

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
                    "상품 이름 : ",
                  ),
                  CustomWidget.buildTitle(
                    userName,
                    weight: FontWeight.w200,
                  )
                ],
              ),
              Row(
                children: [
                  CustomWidget.buildTitle(
                    "상품 내용 : ",
                  ),
                  CustomWidget.buildTitle(
                    productName,
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
                controller: reasonController,
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
                String reason = reasonController.text;
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
