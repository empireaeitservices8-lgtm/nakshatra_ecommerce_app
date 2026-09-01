import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_models.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/user_viewmodel.dart';

class AddUserScreen extends StatefulWidget {
  static const String routeName = '/users/add';

  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'Operator';
  final _formKey = GlobalKey<FormState>();

  final List<String> _roles = const [
    'Store Manager',
    'Chief Appraiser',
    'Cashier & Billing',
    'Operator',
    'Support Specialist',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final req = AddUserRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    final success = await userVM.addUser(req);
    if (!mounted) return;

    if (success) {
      context.showSnackBar('User added successfully');
      Navigator.pop(context);
    } else {
      context.showSnackBar('Failed to add user', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();

    return Scaffold(
      appBar: buildAppBar(title: 'Add System User'),
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
                  labelText: 'Full Name',
                  hintText: 'e.g. Ananya Sharma',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'e.g. ananya.s@nakshatra.in',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: '10-digit mobile number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (val) => val == null || val.length < 10 ? 'Valid phone required' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'System Role',
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
                      value: _selectedRole,
                      items: _roles
                          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Add User',
                  backgroundColor: AppPalette.emerald,
                  isLoading: userVM.isBusy,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ).showProgressOnCenter(isLoading: userVM.isBusy),
    );
  }
}
