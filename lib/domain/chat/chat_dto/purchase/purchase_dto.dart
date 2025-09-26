import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';

class PurchaseDto {
  String paymentKey;
  String orderId;
  num amount;

  PurchaseDto({
    required this.paymentKey,
    required this.orderId,
    required this.amount,
  });

  static Map<String, dynamic> toMap(Success success) {
    return {
      "paymentKey": success.paymentKey ?? '',
      "orderId": success.orderId ?? '',
      "amount": success.amount ?? 0
    };
  }

  PurchaseDto copyWith({
    String? paymentKey,
    String? orderId,
    int? amount,
  }) {
    return PurchaseDto(
      paymentKey: paymentKey ?? this.paymentKey,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
    );
  }
}
