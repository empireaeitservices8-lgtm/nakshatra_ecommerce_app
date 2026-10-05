import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/payment_method.dart';

/// Outcome of a Razorpay checkout attempt.
class RazorpayResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? walletName;
  final String? errorMessage;
  final bool cancelled;

  const RazorpayResult._({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.walletName,
    this.errorMessage,
    this.cancelled = false,
  });
}

/// Thin wrapper that turns Razorpay's event callbacks into a single Future.
class RazorpayService {
  Razorpay? _razorpay;
  Completer<RazorpayResult>? _completer;

  Future<RazorpayResult> pay({
    required RazorpayConfig config,
    required double amount,
    required String name,
    String description = 'Order Payment',
    String? contact,
    String? email,
    String? orderId,
    String? preferredUpiId,
  }) {
    if (_completer != null && !_completer!.isCompleted) {
      return _completer!.future;
    }
    _completer = Completer<RazorpayResult>();

    _razorpay?.clear();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final options = <String, dynamic>{
      'key': config.keyId,
      // Razorpay expects the smallest currency unit (paise for INR).
      'amount': (amount * 100).round(),
      'currency': config.currency,
      'name': name,
      'description': description,
      if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
      'prefill': {
        if (contact != null && contact.isNotEmpty) 'contact': contact,
        if (email != null && email.isNotEmpty) 'email': email,
        if (preferredUpiId != null && preferredUpiId.isNotEmpty)
          'vpa': preferredUpiId,
      },
      'theme': {'color': '#EAA123'},
      'retry': {'enabled': true, 'max_count': 2},
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _complete(RazorpayResult._(success: false, errorMessage: e.toString()));
    }
    return _completer!.future;
  }

  void _onSuccess(PaymentSuccessResponse r) {
    _complete(RazorpayResult._(
      success: true,
      paymentId: r.paymentId,
      orderId: r.orderId,
      signature: r.signature,
    ));
  }

  void _onError(PaymentFailureResponse r) {
    final cancelled = r.code == Razorpay.PAYMENT_CANCELLED;
    _complete(RazorpayResult._(
      success: false,
      cancelled: cancelled,
      errorMessage: cancelled
          ? 'Payment cancelled'
          : (r.message?.isNotEmpty == true ? r.message : 'Payment failed'),
    ));
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    _complete(RazorpayResult._(
      success: false,
      walletName: r.walletName,
      errorMessage: 'External wallet selected: ${r.walletName ?? ''}',
    ));
  }

  void _complete(RazorpayResult result) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(result);
    }
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
