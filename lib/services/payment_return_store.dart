import '../models/booking_flow_models.dart';

enum PaymentReturnStatus { success, failed }

class PaymentReturnData {
  const PaymentReturnData({
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.selectedFoods,
    required this.total,
    required this.paymentMethod,
    required this.txnRef,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double total;
  final String paymentMethod;
  final String txnRef;

  Map<String, dynamic> toRouteArguments() {
    return {
      'movieTitle': movieTitle,
      'session': session,
      'selectedSeats': selectedSeats,
      'selectedFoods': selectedFoods,
      'total': total,
      'paymentMethod': paymentMethod,
      'txnRef': txnRef,
    };
  }
}

class PaymentReturnStore {
  const PaymentReturnStore._();

  static PaymentReturnData? _pendingPayment;
  static PaymentReturnStatus? _lastStatus;
  static String? _lastTxnRef;

  static void savePending(PaymentReturnData payment) {
    _pendingPayment = payment;
  }

  static PaymentReturnData? get pendingPayment => _pendingPayment;

  static PaymentReturnData? consumePending({String? txnRef}) {
    final payment = _pendingPayment;
    if (payment == null) return null;

    if (txnRef != null && txnRef.isNotEmpty && payment.txnRef != txnRef) {
      return null;
    }

    _pendingPayment = null;
    return payment;
  }

  static void clearPending() {
    _pendingPayment = null;
  }

  static void markResult({
    required PaymentReturnStatus status,
    String? txnRef,
  }) {
    _lastStatus = status;
    _lastTxnRef = txnRef;
  }

  static PaymentReturnStatus? consumeResult({String? txnRef}) {
    if (_lastStatus == null) return null;

    if (txnRef != null &&
        txnRef.isNotEmpty &&
        _lastTxnRef != null &&
        _lastTxnRef != txnRef) {
      return null;
    }

    final status = _lastStatus;
    _lastStatus = null;
    _lastTxnRef = null;
    return status;
  }

  static void clear() {
    clearPending();
    _lastStatus = null;
    _lastTxnRef = null;
  }
}
