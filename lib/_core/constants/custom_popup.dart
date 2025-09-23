import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/community/community_dto/community_detail_dto.dart';
import '../../domain/community/community_provider/community_post_write_notifier.dart';
import '../../domain/members/providers/member_auth_provider.dart';
import '../../domain/product/providers/product_detail_notifier.dart';
import '../../domain/product/providers/product_list_notifier.dart';
import '../../domain/report/report_notifier/product_report_notifier.dart';
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
            if (!isOwner)
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: CustomWidget.buildTitle("신고하기", weight: FontWeight.w200),
                onTap: () {
                  Navigator.pop(context);
                  showReportPopUp(
                      context, userName, productName, productId, ref);
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
      String productName, int productId, WidgetRef ref) {
    final TextEditingController reasonController = TextEditingController();
    final report = ref.read(productReportProvider.notifier);
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
              onPressed: () async {
                String reason = reasonController.text;
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("신고 사유를 입력하세요.")),
                  );
                  return;
                }
                try {
                  await report.saveProductReport(
                      itemId: productId, reason: reason);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("신고가 접수되었습니다.")),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("신고 실패: $e")),
                  );
                  Navigator.pop(context); // 팝업 닫기
                }
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  static Widget buildCommunityAppBarPopUp(
    BuildContext context,
    CommunityDetailDto dto,
    WidgetRef ref,
  ) {
    // 현재 로그인된 유저 ID 가져오기 (예시)
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.loginId;

    // 게시글 작성자 ID와 현재 유저 ID가 같은지 확인
    final isOwner = currentUserId != null && currentUserId == dto.writerName;

    // 게시글 삭제 Notifier
    final communityNotifier = ref.read(communityPostWriteProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOwner) ...[
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
            title: CustomWidget.buildTitle("수정하기", weight: FontWeight.w200),
            onTap: () {
              Navigator.pop(context);
              // TODO: 수정 페이지로 이동하는 로직 추가
              // Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityEditPage(dto: dto)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: CustomWidget.buildTitle("삭제하기", weight: FontWeight.w200),
            onTap: () async {
              Navigator.pop(context);
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("삭제 확인"),
                  content: const Text("정말로 이 게시물을 삭제하시겠습니까?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("취소"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await communityNotifier.deletePost(dto.id);
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // 다이얼로그 닫기
                        Navigator.pop(context); // 상세 페이지 닫고 목록으로 돌아가기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("삭제"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        ListTile(
          leading: const Icon(Icons.report, color: Colors.red),
          title: CustomWidget.buildTitle("신고하기", weight: FontWeight.w200),
          onTap: () {
            Navigator.pop(context);
            // TODO: 신고 팝업 띄우는 로직 추가
          },
        ),
        ListTile(
          leading: const Icon(Icons.close, color: Colors.grey),
          title: const Text("닫기"),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
