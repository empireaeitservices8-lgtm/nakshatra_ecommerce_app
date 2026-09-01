import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/device_models.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/device_viewmodel.dart';
import 'add_device_screen.dart';
import 'device_detail_screen.dart';

class DeviceListScreen extends StatefulWidget {
  static const String routeName = '/devices';

  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<DeviceViewModel>(context, listen: false);
      vm.loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceVM = context.watch<DeviceViewModel>();
    final devices = deviceVM.list;

    return Scaffold(
      appBar: buildAppBar(
        title: 'Connected Devices',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppPalette.emerald),
            onPressed: () => Navigator.pushNamed(context, AddDeviceScreen.routeName),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => deviceVM.loadFirstPage(),
        child: devices.isEmpty && !deviceVM.isLoading
            ? const Center(child: Text('No devices found')).orShowEmptyWidget(
                items: devices,
                isLoading: deviceVM.isLoading,
                text: 'No connected devices found',
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: devices.length + (deviceVM.isLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index >= devices.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final device = devices[index];
                  final isOnline = device.status.toLowerCase() == 'online';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        deviceVM.setSelectedDevice(device);
                        Navigator.pushNamed(
                          context,
                          DeviceDetailScreen.routeName,
                          arguments: device,
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: isOnline
                            ? AppPalette.emerald.withOpacity(0.12)
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.device_hub_rounded,
                          color: isOnline ? AppPalette.emerald : Colors.grey,
                        ),
                      ),
                      title: Text(
                        device.deviceName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      subtitle: Text(
                        'Type: ${device.deviceType} • SN: ${device.serialNumber}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          device.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOnline ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).withLoadMore(
                onLoadMore: (_) => deviceVM.loadNextPage(),
                canLoadMore: (_) => !deviceVM.isAllCompleted && !deviceVM.isLoading,
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: 'Add New Device',
          onPressed: () => Navigator.pushNamed(context, AddDeviceScreen.routeName),
        ),
      ),
    );
  }
}
