import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../devices/view/device_list_screen.dart';
import '../../device_groups/view/device_group_list_screen.dart';
import '../../users/view/user_list_screen.dart';
import '../view_model/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVM = context.watch<DashboardViewModel>();
    final counts = dashboardVM.deviceUserCount;
    final license = dashboardVM.licenseSummary;

    return Scaffold(
      appBar: buildAppBar(
        title: 'Enterprise Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => dashboardVM.fetchDashboardData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboardVM.fetchDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // License Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppPalette.emerald, AppPalette.emeraldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.emerald.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'License Status',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppPalette.gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            license?.status ?? 'Active',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      license?.licenseKey ?? 'NAK-ENT-2026-X99',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildMetricChip('Used: ${license?.usedLicenses ?? 0}/${license?.totalLicenses ?? 0}'),
                        const SizedBox(width: 8),
                        _buildMetricChip('Expires: ${license?.expiryDate ?? '2027-12-31'}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary Stats Section
              const Text(
                'Overview Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Devices',
                      value: '${counts?.totalDevices ?? 0}',
                      subtext: '${counts?.activeDevices ?? 0} Active',
                      icon: Icons.devices_rounded,
                      color: AppPalette.emerald,
                      onTap: () => Navigator.pushNamed(context, DeviceListScreen.routeName),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Users',
                      value: '${counts?.totalUsers ?? 0}',
                      subtext: '${counts?.activeUsers ?? 0} Active',
                      icon: Icons.people_alt_rounded,
                      color: AppPalette.goldDark,
                      onTap: () => Navigator.pushNamed(context, UserListScreen.routeName),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Module Quick Navigation
              const Text(
                'Management Modules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildModuleTile(
                title: 'Device Management',
                subtitle: 'Monitor, add, and reassign hardware devices',
                icon: Icons.developer_board_rounded,
                onTap: () => Navigator.pushNamed(context, DeviceListScreen.routeName),
              ),
              const SizedBox(height: 8),
              _buildModuleTile(
                title: 'Device Groups',
                subtitle: 'Group devices by department or location',
                icon: Icons.hub_rounded,
                onTap: () => Navigator.pushNamed(context, DeviceGroupListScreen.routeName),
              ),
              const SizedBox(height: 8),
              _buildModuleTile(
                title: 'User Management',
                subtitle: 'Manage staff, operators, and permissions',
                icon: Icons.manage_accounts_rounded,
                onTap: () => Navigator.pushNamed(context, UserListScreen.routeName),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              AppButton.curvedButton(
                text: 'Go to Jewellery Shop',
                backgroundColor: AppPalette.emerald,
                textColor: Colors.white,
                onTap: () => Navigator.pushReplacementNamed(context, '/home'),
              ),
            ],
          ),
        ),
      ).showProgressOnCenter(isLoading: dashboardVM.isBusy),
    );
  }

  Widget _buildMetricChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(subtext, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppPalette.emerald.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppPalette.emerald),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 22, color: Colors.grey),
    );
  }
}
