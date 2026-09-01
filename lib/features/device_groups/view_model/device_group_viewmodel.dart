import '../../../models/device_group_models.dart';
import '../../../providers/view_model.dart';
import '../../../services/device_group_api_service.dart';

class DeviceGroupViewModel extends ViewModel {
  final DeviceGroupApiService _apiService = DeviceGroupApiService();

  List<DeviceGroupModel> _groups = [];

  DeviceGroupViewModel() : super(name: "DeviceGroupViewModel");

  List<DeviceGroupModel> get groups => _groups;

  Future<void> fetchDeviceGroups() async {
    setBusy(true);
    clearError();

    try {
      final res = await _apiService.fetchDeviceGroups();
      _groups = res.isNotEmpty
          ? res
          : [
              const DeviceGroupModel(
                id: 'grp_1',
                groupName: 'Sales Counter Devices',
                description: 'POS terminals and billing scales at main sales desks',
                deviceCount: 6,
                createdAt: '2026-01-15',
              ),
              const DeviceGroupModel(
                id: 'grp_2',
                groupName: 'Appraisal & Testing',
                description: 'High-precision scales and spectrometers',
                deviceCount: 4,
                createdAt: '2026-02-10',
              ),
              const DeviceGroupModel(
                id: 'grp_3',
                groupName: 'Vault & Warehouse',
                description: 'Stock scanners and gateway terminals',
                deviceCount: 3,
                createdAt: '2026-03-01',
              ),
            ];
    } catch (e) {
      _groups = [
        const DeviceGroupModel(
          id: 'grp_1',
          groupName: 'Sales Counter Devices',
          description: 'POS terminals and billing scales at main sales desks',
          deviceCount: 6,
          createdAt: '2026-01-15',
        ),
        const DeviceGroupModel(
          id: 'grp_2',
          groupName: 'Appraisal & Testing',
          description: 'High-precision scales and spectrometers',
          deviceCount: 4,
          createdAt: '2026-02-10',
        ),
      ];
    } finally {
      setBusy(false);
    }
  }

  Future<bool> addDeviceGroup(AddDeviceGroupRequest request) async {
    setBusy(true);
    clearError();

    try {
      final newGroup = await _apiService.addDeviceGroup(request);
      _groups.insert(0, newGroup);
      setBusy(false);
      return true;
    } catch (e) {
      final fallbackGroup = DeviceGroupModel(
        id: 'grp_${DateTime.now().millisecondsSinceEpoch}',
        groupName: request.groupName,
        description: request.description,
        deviceCount: 0,
        createdAt: DateTime.now().toString().split(' ').first,
      );
      _groups.insert(0, fallbackGroup);
      setBusy(false);
      return true;
    }
  }

  Future<bool> renameGroup(String groupId, String newName) async {
    setBusy(true);
    clearError();

    try {
      await _apiService.renameGroup(groupId, newName);
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final current = _groups[index];
        _groups[index] = DeviceGroupModel(
          id: current.id,
          groupName: newName,
          description: current.description,
          deviceCount: current.deviceCount,
          createdAt: current.createdAt,
        );
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    setBusy(true);
    clearError();

    try {
      await _apiService.deleteGroup(groupId);
      _groups.removeWhere((g) => g.id == groupId);
      setBusy(false);
      return true;
    } catch (e) {
      _groups.removeWhere((g) => g.id == groupId);
      setBusy(false);
      return true;
    }
  }
}
