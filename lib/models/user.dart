class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String referralCode;
  final double referralBalance;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.referralCode,
    this.referralBalance = 0.0,
    this.createdAt = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to read ID from multiple possible keys
    final rawId = json['customer_id'] ?? json['id'] ?? '';
    
    // Helper to read referral code from multiple possible keys
    final rawReferralCode = json['referral_code'] ?? json['referralCode'] ?? '';
    
    // Helper to read referral balance
    final rawReferralBalance = json['referral_balance'] ?? json['referralBalance'] ?? 0.0;
    double parsedBalance = 0.0;
    if (rawReferralBalance is num) {
      parsedBalance = rawReferralBalance.toDouble();
    } else if (rawReferralBalance is String) {
      parsedBalance = double.tryParse(rawReferralBalance) ?? 0.0;
    }

    // Helper to read created_at
    final rawCreatedAt = json['created_at'] ?? json['createdAt'] ?? '';

    // Helper to read name (with fallback to first_name + last_name)
    final rawName = json['name'] ?? 
        (json['first_name'] != null 
            ? '${json['first_name']} ${json['last_name'] ?? ''}'.trim() 
            : '');

    return User(
      id: rawId.toString(),
      name: rawName.toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      referralCode: rawReferralCode.toString(),
      referralBalance: parsedBalance,
      createdAt: rawCreatedAt.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'referral_code': referralCode,
      'referral_balance': referralBalance,
      'created_at': createdAt,
    };
  }
}

