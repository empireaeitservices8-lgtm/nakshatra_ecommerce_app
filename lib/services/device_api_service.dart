import '../models/device_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class DeviceApiService {
  final WebAPIService _webAPI = WebAPIService();

  Future<List<DeviceModel>> fetchDevices({int page = 1, int limit = 20}) {
    return _webAPI.executeAPI<List<DeviceModel>>(
      methodToCall: _webAPI.get(
        AppUrls.devices,
        queryParameters: {'page': page, 'limit': limit},
      ),
      converter: (data) {
        final list = (data['devices'] ?? data['data'] ?? []) as List;
        return list.map((item) => DeviceModel.fromJson(item)).toList();
      },
    );
  }

  Future<DeviceModel> addDevice(AddDeviceRequest request) {
    return _webAPI.executeAPI<DeviceModel>(
      methodToCall: _webAPI.post(AppUrls.addDevice, data: request.toJson()),
      converter: (data) => DeviceModel.fromJson(data['device'] ?? data['data'] ?? data),
    );
  }

  Future<bool> removeDevice(String deviceId) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(AppUrls.removeDevice, data: {'device_id': deviceId}),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }

  Future<List<DeviceTypeModel>> fetchDeviceTypes() {
    return _webAPI.executeAPI<List<DeviceTypeModel>>(
      methodToCall: _webAPI.get(AppUrls.deviceTypes),
      converter: (data) {
        final list = (data['types'] ?? data['data'] ?? []) as List;
        return list.map((item) => DeviceTypeModel.fromJson(item)).toList();
      },
    );
  }

  Future<bool> transferKey(String deviceId, String targetUserId) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(
        AppUrls.transferKey,
        data: {'device_id': deviceId, 'target_user_id': targetUserId},
      ),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }
}
