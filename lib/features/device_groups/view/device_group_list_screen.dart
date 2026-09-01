import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/device_group_models.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/device_group_viewmodel.dart';
import 'create_device_group_dialog.dart';

class DeviceGroupListScreen extends StatefulWidget {
  static const String routeName = '/device-groups';

  const DeviceGroupListScreen({super.key});

  @override
  State<DeviceGroupListScreen> createState() => _DeviceGroupListScreenState();
}

class _DeviceGroupListScreenState extends State<DeviceGroupListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceGroupViewModel>(context, listen: false).fetchDeviceGroups();
    });
  }

  Future<void> _openCreateDialog() async {
    final req = await showDialog<AddDeviceGroupRequest>(
      context: context,
      builder: (_) => const CreateDeviceGroupDialog(),
    );

    if (req != null && mounted) {
      final vm = Provider.of<DeviceGroupViewModel>(context, listen: false);
      final success = await vm.addDeviceGroup(req);
      if (mounted) {
        context.showSnackBar(success ? 'Group created' : 'Failed to create group');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupVM = context.watch<DeviceGroupViewModel>();
    final groups = groupVM.groups;

    return Scaffold(
      appBar: buildAppBar(
        title: 'Device Groups',
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded, color: AppPalette.emerald),
            onPressed: _openCreateDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => groupVM.fetchDeviceGroups(),
        child: groups.isEmpty && !groupVM.isBusy
            ? const Center(child: Text('No groups found')).orShowEmptyWidget(
                items: groups,
                isLoading: groupVM.isBusy,
                text: 'No device groups configured yet',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  group.groupName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppPalette.emerald.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${group.deviceCount} Devices',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppPalette.emerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            group.description,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Created: ${group.createdAt}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Group'),
                                      content: Text('Delete "${group.groupName}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await groupVM.deleteGroup(group.id);
                                    if (mounted) context.showSnackBar('Group deleted');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ).showProgressOnCenter(isLoading: groupVM.isBusy),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: 'Create New Group',
          onPressed: _openCreateDialog,
        ),
      ),
    );
  }
}
