class AppUrls {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String verifyLogin = '/auth/verify-login';
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String enableBiometric = '/auth/enable-biometric';

  // Dashboard endpoints
  static const String deviceUserCount = '/dashboard/device-user-count';
  static const String licenseSummary = '/dashboard/license-summary';

  // Device endpoints
  static const String devices = '/devices';
  static const String addDevice = '/devices/add';
  static const String removeDevice = '/devices/remove';
  static const String deviceTypes = '/devices/types';
  static const String transferKey = '/devices/transfer-key';

  // Device Group endpoints
  static const String deviceGroups = '/device-groups';
  static const String addDeviceGroup = '/device-groups/add';
  static const String addDeviceToGroup = '/device-groups/add-device';
  static const String renameGroup = '/device-groups/rename';
  static const String deleteGroup = '/device-groups/delete';

  // User endpoints
  static const String users = '/users';
  static const String addUser = '/users/add';
  static const String deleteUserDevice = '/users/delete-device';
  static const String deleteUserGroup = '/users/delete-group';
}
