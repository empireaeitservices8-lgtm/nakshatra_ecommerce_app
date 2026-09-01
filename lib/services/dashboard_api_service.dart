import '../models/dashboard_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class DashboardApiService {
  final WebAPIService _webAPI = WebAPIService();

  Future<DeviceUserCountModel> fetchDeviceUserCount() {
    return _webAPI.executeAPI<DeviceUserCountModel>(
      methodToCall: _webAPI.get(AppUrls.deviceUserCount),
      converter: (data) => DeviceUserCountModel.fromJson(data['data'] ?? data),
    );
  }

  Future<LicenseSummaryModel> fetchLicenseSummary() {
    return _webAPI.executeAPI<LicenseSummaryModel>(
      methodToCall: _webAPI.get(AppUrls.licenseSummary),
      converter: (data) => LicenseSummaryModel.fromJson(data['data'] ?? data),
    );
  }
}
