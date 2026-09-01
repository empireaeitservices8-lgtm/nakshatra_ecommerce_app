import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/device_models.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/device_viewmodel.dart';

class AddDeviceScreen extends StatefulWidget {
  static const String routeName = '/devices/add';

  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();
  final _assignController = TextEditingController();
  String _selectedTypeId = '1';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceViewModel>(context, listen: false).fetchDeviceTypes();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _assignController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final deviceVM = Provider.of<DeviceViewModel>(context, listen: false);
    final req = AddDeviceRequest(
      deviceName: _nameController.text.trim(),
      deviceTypeId: _selectedTypeId,
      serialNumber: _serialController.text.trim(),
      assignedToUserId: _assignController.text.trim().isEmpty ? null : _assignController.text.trim(),
    );

    final success = await deviceVM.addDevice(req);
    if (!mounted) return;

    if (success) {
      context.showSnackBar('Device registered successfully');
      Navigator.pop(context);
    } else {
      context.showSnackBar('Failed to register device', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceVM = context.watch<DeviceViewModel>();
    final types = deviceVM.deviceTypes;

    return Scaffold(
      appBar: buildAppBar(title: 'Register New Device'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Device Name',
                  hintText: 'e.g. Weighing Scale Counter 3',
                  prefixIcon: const Icon(Icons.label_outline_rounded, size: 20),
                  validator: (val) => val == null || val.isEmpty ? 'Device name required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _serialController,
                  labelText: 'Serial Number',
                  hintText: 'e.g. SN-99824-A',
                  prefixIcon: const Icon(Icons.qr_code_2_rounded, size: 20),
                  validator: (val) => val == null || val.isEmpty ? 'Serial number required' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Device Type',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: types.any((t) => t.id == _selectedTypeId) ? _selectedTypeId : (types.isNotEmpty ? types.first.id : null),
                      items: types
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.typeName)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTypeId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _assignController,
                  labelText: 'Assign to Desk / Operator (Optional)',
                  hintText: 'e.g. Counter 2 or Staff ID',
                  prefixIcon: const Icon(Icons.person_pin_circle_outlined, size: 20),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Register Device',
                  isLoading: deviceVM.isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ).showProgressOnCenter(isLoading: deviceVM.isLoading),
    );
  }
}
