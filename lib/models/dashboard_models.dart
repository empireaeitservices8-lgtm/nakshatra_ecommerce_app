class DeviceUserCountModel {
  final int totalDevices;
  final int activeDevices;
  final int totalUsers;
  final int activeUsers;

  const DeviceUserCountModel({
    required this.totalDevices,
    required this.activeDevices,
    required this.totalUsers,
    required this.activeUsers,
  });

  factory DeviceUserCountModel.fromJson(Map<dynamic, dynamic> json) =>
      DeviceUserCountModel(
        totalDevices: json['total_devices'] as int? ?? 0,
        activeDevices: json['active_devices'] as int? ?? 0,
        totalUsers: json['total_users'] as int? ?? 0,
        activeUsers: json['active_users'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'total_devices': totalDevices,
        'active_devices': activeDevices,
        'total_users': totalUsers,
        'active_users': activeUsers,
      };
}

class LicenseSummaryModel {
  final String licenseKey;
  final String status;
  final int totalLicenses;
  final int usedLicenses;
  final String expiryDate;

  const LicenseSummaryModel({
    required this.licenseKey,
    required this.status,
    required this.totalLicenses,
    required this.usedLicenses,
    required this.expiryDate,
  });

  factory LicenseSummaryModel.fromJson(Map<dynamic, dynamic> json) =>
      LicenseSummaryModel(
        licenseKey: json['license_key'] as String? ?? '',
        status: json['status'] as String? ?? 'Active',
        totalLicenses: json['total_licenses'] as int? ?? 0,
        usedLicenses: json['used_licenses'] as int? ?? 0,
        expiryDate: json['expiry_date'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'license_key': licenseKey,
        'status': status,
        'total_licenses': totalLicenses,
        'used_licenses': usedLicenses,
        'expiry_date': expiryDate,
      };
}
