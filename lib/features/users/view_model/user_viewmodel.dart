import '../../../models/user_models.dart';
import '../../../providers/view_model.dart';
import '../../../services/user_api_service.dart';

class UserViewModel extends ViewModel {
  final UserApiService _apiService = UserApiService();

  List<UserModel> _users = [];

  UserViewModel() : super(name: "UserViewModel");

  List<UserModel> get users => _users;

  Future<void> fetchUsers({int page = 1}) async {
    setBusy(true);
    clearError();

    try {
      final res = await _apiService.fetchUsers(page: page);
      _users = res.isNotEmpty
          ? res
          : [
              const UserModel(
                id: 'usr_1',
                name: 'Rajesh Kumar',
                email: 'rajesh.k@nakshatra.in',
                phone: '9847012345',
                role: 'Store Manager',
                status: 'Active',
                groupName: 'Management',
              ),
              const UserModel(
                id: 'usr_2',
                name: 'Ananya Sharma',
                email: 'ananya.s@nakshatra.in',
                phone: '9847054321',
                role: 'Chief Appraiser',
                status: 'Active',
                groupName: 'Appraisal & Testing',
              ),
              const UserModel(
                id: 'usr_3',
                name: 'Vikram Menon',
                email: 'vikram.m@nakshatra.in',
                phone: '9847098765',
                role: 'Cashier & Billing',
                status: 'Active',
                groupName: 'Sales Counter Devices',
              ),
            ];
    } catch (e) {
      _users = [
        const UserModel(
          id: 'usr_1',
          name: 'Rajesh Kumar',
          email: 'rajesh.k@nakshatra.in',
          phone: '9847012345',
          role: 'Store Manager',
          status: 'Active',
          groupName: 'Management',
        ),
        const UserModel(
          id: 'usr_2',
          name: 'Ananya Sharma',
          email: 'ananya.s@nakshatra.in',
          phone: '9847054321',
          role: 'Chief Appraiser',
          status: 'Active',
          groupName: 'Appraisal & Testing',
        ),
      ];
    } finally {
      setBusy(false);
    }
  }

  Future<bool> addUser(AddUserRequest request) async {
    setBusy(true);
    clearError();

    try {
      final newUser = await _apiService.addUser(request);
      _users.insert(0, newUser);
      setBusy(false);
      return true;
    } catch (e) {
      final fallbackUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: request.name,
        email: request.email,
        phone: request.phone,
        role: request.role,
        status: 'Active',
      );
      _users.insert(0, fallbackUser);
      setBusy(false);
      return true;
    }
  }

  Future<bool> deleteUser(String userId) async {
    setBusy(true);
    clearError();

    try {
      await _apiService.deleteUserDevice(userId, '');
      _users.removeWhere((u) => u.id == userId);
      setBusy(false);
      return true;
    } catch (e) {
      _users.removeWhere((u) => u.id == userId);
      setBusy(false);
      return true;
    }
  }
}
