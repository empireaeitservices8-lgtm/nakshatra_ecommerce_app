import '../models/device_group_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class DeviceGroupApiService {
  final WebAPIService _webAPI = WebAPIService();

  Future<List<DeviceGroupModel>> fetchDeviceGroups() {
    return _webAPI.executeAPI<List<DeviceGroupModel>>(
      methodToCall: _webAPI.get(AppUrls.deviceGroups),
      converter: (data) {
        final list = (data['groups'] ?? data['data'] ?? []) as List;
        return list.map((item) => DeviceGroupModel.fromJson(item)).toList();
      },
    );
  }

  Future<DeviceGroupModel> addDeviceGroup(AddDeviceGroupRequest request) {
    return _webAPI.executeAPI<DeviceGroupModel>(
      methodToCall: _webAPI.post(AppUrls.addDeviceGroup, data: request.toJson()),
      converter: (data) => DeviceGroupModel.fromJson(data['group'] ?? data['data'] ?? data),
    );
  }

  Future<bool> addDeviceToGroup(String groupId, String deviceId) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(
        AppUrls.addDeviceToGroup,
        data: {'group_id': groupId, 'device_id': deviceId},
      ),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }

  Future<bool> renameGroup(String groupId, String newName) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(
        AppUrls.renameGroup,
        data: {'group_id': groupId, 'new_name': newName},
      ),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }

  Future<bool> deleteGroup(String groupId) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(AppUrls.deleteGroup, data: {'group_id': groupId}),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }
}
