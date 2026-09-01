import '../models/user_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class UserApiService {
  final WebAPIService _webAPI = WebAPIService();

  Future<List<UserModel>> fetchUsers({int page = 1, int limit = 20}) {
    return _webAPI.executeAPI<List<UserModel>>(
      methodToCall: _webAPI.get(
        AppUrls.users,
        queryParameters: {'page': page, 'limit': limit},
      ),
      converter: (data) {
        final list = (data['users'] ?? data['data'] ?? []) as List;
        return list.map((item) => UserModel.fromJson(item)).toList();
      },
    );
  }

  Future<UserModel> addUser(AddUserRequest request) {
    return _webAPI.executeAPI<UserModel>(
      methodToCall: _webAPI.post(AppUrls.addUser, data: request.toJson()),
      converter: (data) => UserModel.fromJson(data['user'] ?? data['data'] ?? data),
    );
  }

  Future<bool> deleteUserDevice(String userId, String deviceId) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(
        AppUrls.deleteUserDevice,
        data: {'user_id': userId, 'device_id': deviceId},
      ),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }

  Future<bool> deleteUserGroup(String userId, String groupId) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(
        AppUrls.deleteUserGroup,
        data: {'user_id': userId, 'group_id': groupId},
      ),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }
}
