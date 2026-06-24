import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  PaymentService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  String get _baseUrl {
    final envUrl = dotenv.env['VNPAY_BACKEND_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl.replaceFirst(RegExp(r'/$'), '');
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  Future<VnPayPaymentSession> createVnPayPaymentUrl({
    required String bookingId,
    required double amount,
    required String orderInfo,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/vnpay/create-payment-url');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'bookingId': bookingId,
        'amount': amount.round(),
        'orderInfo': orderInfo,
      }),
    );

    final response = await request.close().timeout(const Duration(seconds: 12));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(body));
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final paymentUrl = json['paymentUrl'] as String?;
    if (paymentUrl == null || paymentUrl.trim().isEmpty) {
      throw Exception('VNPay server did not return a payment URL.');
    }

    return VnPayPaymentSession(
      paymentUrl: paymentUrl,
      txnRef: json['txnRef'] as String? ?? bookingId,
    );
  }

  String _extractMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String? ?? 'Cannot create VNPay payment URL.';
    } catch (_) {
      return 'Cannot create VNPay payment URL.';
    }
  }
}

class VnPayPaymentSession {
  const VnPayPaymentSession({required this.paymentUrl, required this.txnRef});

  final String paymentUrl;
  final String txnRef;
}
