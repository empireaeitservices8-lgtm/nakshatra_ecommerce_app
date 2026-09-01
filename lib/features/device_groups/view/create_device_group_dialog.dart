import 'package:flutter/material.dart';
import '../../../models/device_group_models.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';

class CreateDeviceGroupDialog extends StatefulWidget {
  const CreateDeviceGroupDialog({super.key});

  @override
  State<CreateDeviceGroupDialog> createState() => _CreateDeviceGroupDialogState();
}

class _CreateDeviceGroupDialogState extends State<CreateDeviceGroupDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Device Group',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Group Name',
                hintText: 'e.g. Counter Billing Group',
                validator: (val) => val == null || val.isEmpty ? 'Group name required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descController,
                labelText: 'Description',
                hintText: 'Purpose or location of this group',
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Create Group',
                backgroundColor: AppPalette.emerald,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final req = AddDeviceGroupRequest(
                    groupName: _nameController.text.trim(),
                    description: _descController.text.trim(),
                  );
                  Navigator.pop(context, req);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
