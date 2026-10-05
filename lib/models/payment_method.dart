class PaymentMethod {
  final String id;
  final String number;
  final String expiry;
  final String holder;
  final String brand;
  final String theme;

  PaymentMethod({
    required this.id,
    required this.number,
    required this.expiry,
    required this.holder,
    required this.brand,
    required this.theme,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: (json['card_id'] ?? json['id'] ?? '').toString(),
      number: (json['number'] ?? json['card_number'] ?? '').toString(),
      expiry: (json['expiry'] ?? '').toString(),
      holder: (json['holder'] ?? json['card_holder_name'] ?? '').toString(),
      brand: (json['brand'] ?? json['card_type'] ?? '').toString(),
      theme: (json['theme'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'expiry': expiry,
      'holder': holder,
      'brand': brand,
      'theme': theme,
    };
  }
}

class UpiProfile {
  final String id;
  final String upiId;
  final String status;

  UpiProfile({required this.id, required this.upiId, required this.status});

  bool get isActive => status.toLowerCase() == 'active';

  factory UpiProfile.fromJson(Map<String, dynamic> json) {
    return UpiProfile(
      id: (json['id'] ?? '').toString(),
      upiId: (json['upi_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class RazorpayConfig {
  final String keyId;
  final bool enabled;
  final String currency;

  RazorpayConfig({
    required this.keyId,
    required this.enabled,
    required this.currency,
  });

  bool get isUsable => enabled && keyId.isNotEmpty;

  factory RazorpayConfig.fromJson(Map<String, dynamic> json) {
    return RazorpayConfig(
      keyId: (json['key_id'] ?? '').toString(),
      enabled: json['enabled'] == true,
      currency: (json['currency'] ?? 'INR').toString(),
    );
  }
}

/// Parsed response of `/payment_methods`.
class PaymentMethodsResult {
  final List<PaymentMethod> cards;
  final List<UpiProfile> upiProfiles;
  final RazorpayConfig? razorpay;

  PaymentMethodsResult({
    required this.cards,
    required this.upiProfiles,
    this.razorpay,
  });

  factory PaymentMethodsResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(dynamic e) =>
        e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);

    final rp = json['razorpay'];
    return PaymentMethodsResult(
      cards: ((json['cards'] as List?) ?? [])
          .map((e) => PaymentMethod.fromJson(asMap(e)))
          .toList(),
      upiProfiles: ((json['upi_profiles'] as List?) ?? [])
          .map((e) => UpiProfile.fromJson(asMap(e)))
          .toList(),
      razorpay: rp is Map ? RazorpayConfig.fromJson(asMap(rp)) : null,
    );
  }
}
