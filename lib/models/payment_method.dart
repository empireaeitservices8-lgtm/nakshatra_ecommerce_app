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
      number: json['number'] ?? '',
      expiry: json['expiry'] ?? '',
      holder: json['holder'] ?? '',
      brand: json['brand'] ?? '',
      theme: json['theme'] ?? '',
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
