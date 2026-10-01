class User {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String city;
  final int? branchId;
  final String branchName;
  final String authToken;
  final String tokenExpiry;
  final String referralCode;
  final double referralBalance;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    required this.phone,
    required this.email,
    this.city = '',
    this.branchId,
    this.branchName = '',
    this.authToken = '',
    this.tokenExpiry = '',
    required this.referralCode,
    this.referralBalance = 0.0,
    this.createdAt = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper to read ID from multiple possible keys
    final rawId = json['customer_id'] ?? json['id'] ?? '';

    // Helper to read referral code from multiple possible keys
    final rawReferralCode =
        json['referral_code'] ?? json['referralCode'] ?? '';

    // Helper to read referral balance
    final rawReferralBalance =
        json['referral_balance'] ?? json['referralBalance'] ?? 0.0;
    double parsedBalance = 0.0;
    if (rawReferralBalance is num) {
      parsedBalance = rawReferralBalance.toDouble();
    } else if (rawReferralBalance is String) {
      parsedBalance = double.tryParse(rawReferralBalance) ?? 0.0;
    }

    // Helper to read created_at
    final rawCreatedAt = json['created_at'] ?? json['createdAt'] ?? '';

    // Helper to read first/last name
    final firstName = (json['first_name'] ?? '').toString();
    final lastName = (json['last_name'] ?? '').toString();

    // Helper to read name (with fallback to first_name + last_name)
    final rawName = json['name'] ??
        (firstName.isNotEmpty
            ? '$firstName $lastName'.trim()
            : '');

    // Helper to read city safely (handling bool false / null / string)
    final rawCity = json['city'];
    final String cityStr = (rawCity is String) ? rawCity : '';

    // Helper to read branch info
    final rawBranchId = json['branch_id'];
    final int? branchId = rawBranchId is int
        ? rawBranchId
        : (rawBranchId != null ? int.tryParse(rawBranchId.toString()) : null);
    final String branchName =
        (json['branch_name'] ?? json['branch'] ?? '').toString();

    // Helper to read token info
    final String authToken =
        (json['auth_token'] ?? json['token'] ?? json['access_token'] ?? '')
            .toString();
    final String tokenExpiry = (json['token_expiry'] ?? '').toString();

    return User(
      id: rawId.toString(),
      name: rawName.toString(),
      firstName: firstName,
      lastName: lastName,
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      city: cityStr,
      branchId: branchId,
      branchName: branchName,
      authToken: authToken,
      tokenExpiry: tokenExpiry,
      referralCode: rawReferralCode.toString(),
      referralBalance: parsedBalance,
      createdAt: rawCreatedAt.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'city': city,
      'branch_id': branchId,
      'branch_name': branchName,
      'auth_token': authToken,
      'token_expiry': tokenExpiry,
      'referral_code': referralCode,
      'referral_balance': referralBalance,
      'created_at': createdAt,
    };
  }
}
