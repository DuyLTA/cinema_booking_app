import 'package:flutter/material.dart';

import '../../../models/booking_flow_models.dart';
import '../../../services/payment_service.dart';

class PaymentMethodProvider extends ChangeNotifier {
  PaymentMethodProvider({PaymentService? paymentService})
    : _paymentService = paymentService ?? PaymentService();

  final PaymentService _paymentService;

  final List<PaymentMethodModel> methods = const [
    PaymentMethodModel(
      type: PaymentMethodType.vnpayQr,
      name: 'VNPay QR Sandbox',
      shortLabel: 'QR',
      iconColor: 0xFF005BAA,
    ),
  ];

  PaymentMethodType selectedType = PaymentMethodType.vnpayQr;
  bool isProcessing = false;
  bool hasOpenedVnPay = false;
  String? activeVnPayTxnRef;
  String? errorMessage;

  PaymentMethodModel get selectedMethod {
    return methods.firstWhere((method) => method.type == selectedType);
  }

  void select(PaymentMethodType type) {
    selectedType = type;
    errorMessage = null;
    notifyListeners();
  }

  void markVnPayOpened({required String txnRef}) {
    hasOpenedVnPay = true;
    activeVnPayTxnRef = txnRef;
    notifyListeners();
  }

  void resetVnPaySession() {
    hasOpenedVnPay = false;
    activeVnPayTxnRef = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<VnPayPaymentSession> createVnPayPaymentUrl({
    required String bookingId,
    required double amount,
    required String orderInfo,
  }) async {
    isProcessing = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _paymentService.createVnPayPaymentUrl(
        bookingId: bookingId,
        amount: amount,
        orderInfo: orderInfo,
      );
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
