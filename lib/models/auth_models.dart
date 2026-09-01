class RequestOTP {
  final String phone;
  final String? email;

  const RequestOTP({
    required this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        if (email != null) 'email': email,
      };

  factory RequestOTP.fromJson(Map<String, dynamic> json) => RequestOTP(
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
      );
}

class VerifyOTP {
  final String phone;
  final String otp;

  const VerifyOTP({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };

  factory VerifyOTP.fromJson(Map<String, dynamic> json) => VerifyOTP(
        phone: json['phone'] as String? ?? '',
        otp: json['otp'] as String? ?? '',
      );
}

class LoginRequest {
  final String username;
  final String password;
  final String? deviceToken;

  const LoginRequest({
    required this.username,
    required this.password,
    this.deviceToken,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        if (deviceToken != null) 'device_token': deviceToken,
      };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
        deviceToken: json['device_token'] as String?,
      );
}

class AuthResponse {
  final String token;
  final String? userId;
  final String? name;
  final String? email;
  final String? role;

  const AuthResponse({
    required this.token,
    this.userId,
    this.name,
    this.email,
    this.role,
  });

  factory AuthResponse.fromJson(Map<dynamic, dynamic> json) => AuthResponse(
        token: (json['token'] ?? json['auth_token'] ?? json['access_token'] ?? '').toString(),
        userId: (json['user_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'user_id': userId,
        'name': name,
        'email': email,
        'role': role,
      };
}
