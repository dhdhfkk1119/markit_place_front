import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:uuid/uuid.dart';
import '../../../../../../../_core/constants/assets.dart';
import '../../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../../_core/constants/size.dart';
import '../../../../../../../_core/utils/my_http.dart';
import '../../../../../../../domain/chat/chat_dto/purchase/purchase_dto.dart';
import '../../../../../../../domain/product/dtos/product_detail_dto.dart';
import '../../../../../../widgets/custom_button_large.dart';

class TossPurchase extends StatefulWidget {
  ProductDetailDto productDetail;
  final String username;
  TossPurchase(this.productDetail, this.username, {super.key});

  @override
  State<TossPurchase> createState() => _TossPurchaseState();
}

class _TossPurchaseState extends State<TossPurchase> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: Uuid().v5(Uuid.NAMESPACE_URL, widget.username),
    );

    _paymentWidget
        .renderPaymentMethods(
            selector: 'purchase',
            amount: Amount(
                value: widget.productDetail.productList.price,
                currency: Currency.KRW,
                country: "KR"),
            options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"))
        .then((control) {
      _paymentMethodWidgetControl = control;
      setState(() {
        if (mounted) _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes =
        base64ToBytes(widget.productDetail.productList.thumbnail);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("결제 취소 알림"),
                    content: const Text("결제 정보가 초기화됩니다. 그래도 이전으로 가시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text("확인"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          "결제화면",
          style: TextStyle(fontFamily: Assets.Fonts.cookieRun),
        ),
      ),
      body: SafeArea(
          child: Stack(children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      // 기존 Container 대신 상품 정보를 표시하는 위젯으로 대체
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "결제 상품 정보",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget
                                        .productDetail.productList.thumbnail !=
                                    null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // 이미지를 둥글게 처리
                                    child: _isLoading
                                        ? Container(
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey[200],
                                          )
                                        : Image.memory(
                                            imageBytes!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100, // 원하는 높이 설정
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              // 디코딩 실패 시 (Base64 문자열 오류 등)
                                              return Container(
                                                height: 100,
                                                color: Colors.grey[200],
                                                child: Center(
                                                    child: Text("이미지 로드 실패")),
                                              );
                                            },
                                          ),
                                  ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _isLoading
                                        ? Container(
                                            height: 15,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          )
                                        : Text(
                                            "판매자 이름 : ${widget.productDetail.sellerName}", // 가격이 int나 double일 경우, 보기 좋게 표시
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                    SizedBox(height: _isLoading ? 12 : 4),
                                    _isLoading
                                        ? Container(
                                            height: 15,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ))
                                        : Text(
                                            "상품명: ${widget.productDetail.productList.title}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700),
                                          ),
                                    SizedBox(height: _isLoading ? 12 : 4),
                                    // 가격 표시
                                    _isLoading
                                        ? Container(
                                            height: 15,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ))
                                        : Text(
                                            "가격: ${widget.productDetail.productList.price.toStringAsFixed(0)}원", // 가격이 int나 double일 경우, 보기 좋게 표시
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                    SizedBox(height: _isLoading ? 12 : 4),
                                    _isLoading
                                        ? Container(
                                            height: 15,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ))
                                        : Text(
                                            widget.productDetail.productList
                                                    .itemCategoryName.isEmpty
                                                ? "태그 없음"
                                                : widget
                                                    .productDetail
                                                    .productList
                                                    .itemCategoryName,
                                            style: TextStyle(
                                                color: widget
                                                        .productDetail
                                                        .productList
                                                        .itemCategoryName
                                                        .isEmpty
                                                    ? Colors.red[200]
                                                    : Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 16, color: Colors.transparent),
                    PaymentMethodWidget(
                        paymentWidget: _paymentWidget, selector: "purchase"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButtonLarge(
                text: "결제하기",
                onPressed: _isLoading
                    ? null
                    : () async {
                        final response = await _paymentWidget.requestPayment(
                            paymentInfo: PaymentInfo(
                                orderId: Uuid().v5(Uuid.NAMESPACE_URL,
                                    widget.productDetail.productList.title),
                                orderName: widget.username));

                        print("결제 응답 : ${response.success}");
                        if (response.success != null) {
                          final checkResponse =
                              await _checkConfirm(response.success!);

                          if (checkResponse["success"]) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
              ),
            )
          ],
        ),
        if (_isLoading)
          Stack(
            children: [
              Container(
                height: getScreenHeight(context),
                width: getScreenWidth(context),
                color: Color.fromARGB(128, 64, 64, 64),
              ),
              Center(
                child: Container(
                  width: 300,
                  height: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "결제 화면을 불러오고 있어요...",
                      style: TextStyle(
                          fontSize: 20, fontFamily: Assets.Fonts.cookieRun),
                    )
                  ],
                ),
              ),
            ],
          ),
      ])),
    );
  }

  Future<Map<String, dynamic>> _checkConfirm(Success success) async {
    final response = await dio.post("$baseUrl/toss/confirm/payment",
        data: json.encode(PurchaseDto.toMap(success)));
    print("최종 결과 : $response");

    if (response.statusCode == 200) {
      return {"success": true};
    } else {
      return {"success": false};
    }
  }
}
