import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/device_models.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/device_viewmodel.dart';

class DeviceDetailScreen extends StatefulWidget {
  static const String routeName = '/devices/detail';

  final DeviceModel? device;

  const DeviceDetailScreen({super.key, this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final _targetUserCtrl = TextEditingController();

  @override
  void dispose() {
    _targetUserCtrl.dispose();
    super.dispose();
  }

  void _showTransferDialog(BuildContext context, DeviceModel device) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Transfer Device Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the user ID or operator handle to transfer ownership of this device encryption key:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _targetUserCtrl,
              hintText: 'Target User ID',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.emerald),
            onPressed: () async {
              final target = _targetUserCtrl.text.trim();
              if (target.isEmpty) return;
              Navigator.pop(dialogCtx);
              final deviceVM = Provider.of<DeviceViewModel>(context, listen: false);
              final success = await deviceVM.transferKey(device.id, target);
              if (mounted) {
                context.showSnackBar(success ? 'Key transferred to $target' : 'Transfer failed');
              }
            },
            child: const Text('Transfer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceVM = context.watch<DeviceViewModel>();
    final device = widget.device ?? deviceVM.selectedDevice;

    if (device == null) {
      return Scaffold(
        appBar: buildAppBar(title: 'Device Details'),
        body: const Center(child: Text('Device not found')),
      );
    }

    final isOnline = device.status.toLowerCase() == 'online';

    return Scaffold(
      appBar: buildAppBar(title: device.deviceName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppPalette.emerald.withOpacity(0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOnline ? AppPalette.emerald.withOpacity(0.3) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isOnline ? AppPalette.emerald : Colors.grey,
                      child: const Icon(Icons.devices_other_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.deviceName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            device.deviceType,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green.shade600 : Colors.red.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              device.status,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Properties List
              const Text('Device Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildInfoRow('Device ID', device.id),
              _buildInfoRow('Serial Number', device.serialNumber),
              _buildInfoRow('Assigned Desk', device.assignedTo ?? 'Unassigned'),
              _buildInfoRow('IP Address', device.ipAddress ?? '192.168.1.100'),
              const SizedBox(height: 32),

              // Action Buttons
              AppButton(
                text: 'Transfer Encryption Key',
                backgroundColor: AppPalette.emerald,
                onPressed: () => _showTransferDialog(context, device),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Remove Device',
                isBordered: true,
                borderColor: Colors.red,
                textColor: Colors.red,
                isLoading: deviceVM.isLoading,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Removal'),
                      content: Text('Are you sure you want to remove ${device.deviceName}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Remove', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await deviceVM.removeDevice(device.id);
                    if (mounted) {
                      context.showSnackBar('Device removed');
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ).showProgressOnCenter(isLoading: deviceVM.isLoading),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
