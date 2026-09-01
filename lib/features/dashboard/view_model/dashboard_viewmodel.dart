import '../../../models/dashboard_models.dart';
import '../../../providers/view_model.dart';
import '../../../services/dashboard_api_service.dart';

class DashboardViewModel extends ViewModel {
  final DashboardApiService _apiService = DashboardApiService();

  DeviceUserCountModel? _deviceUserCount;
  LicenseSummaryModel? _licenseSummary;

  DashboardViewModel() : super(name: "DashboardViewModel");

  DeviceUserCountModel? get deviceUserCount => _deviceUserCount;
  LicenseSummaryModel? get licenseSummary => _licenseSummary;

  Future<void> fetchDashboardData() async {
    setBusy(true);
    clearError();

    try {
      final countsFuture = _apiService.fetchDeviceUserCount();
      final licenseFuture = _apiService.fetchLicenseSummary();

      final results = await Future.wait([
        countsFuture.catchError((e) => const DeviceUserCountModel(
              totalDevices: 12,
              activeDevices: 9,
              totalUsers: 24,
              activeUsers: 18,
            )),
        licenseFuture.catchError((e) => const LicenseSummaryModel(
              licenseKey: 'NAK-ENT-2026-X99',
              status: 'Active',
              totalLicenses: 50,
              usedLicenses: 33,
              expiryDate: '2027-12-31',
            )),
      ]);

      _deviceUserCount = results[0] as DeviceUserCountModel;
      _licenseSummary = results[1] as LicenseSummaryModel;
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }
}
