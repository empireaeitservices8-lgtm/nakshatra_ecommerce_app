import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/sp_helper.dart';
import '../helpers/toast_helper.dart';
import '../models/branch.dart';
import '../services/token_manager.dart';
import '../utils/app_palette.dart';
import '../utils/extensions.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_button_widget.dart';
import '../widgets/app_custom_text_field.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_checkbox_widget.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  static const String path = '/register';
  static const String signupPath = '/signup';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Branch? _selectedBranch;
  bool _agreeTerms = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<AuthViewModel>().fetchBranches();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null) {
      ToastHelper.showErrorToast(context, 'Please select a branch');
      return;
    }
    if (!_agreeTerms) {
      ToastHelper.showErrorToast(
        context,
        'Please agree to terms and privacy policy',
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      branchId: _selectedBranch?.id,
    );

    if (!mounted) return;

    if (success) {
      final token = SPHelper.getToken();
      if (token != null && token.isNotEmpty && TokenManager.hasToken) {
        ToastHelper.showSuccessToast(context, 'Account created successfully!');
        Navigator.pushReplacementNamed(context, MainScreen.path);
      } else {
        ToastHelper.showSuccessToast(
          context,
          'Account created successfully! Please sign in.',
        );
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    } else {
      ToastHelper.showErrorToast(
        context,
        authVM.errorMessage ?? 'Registration failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: buildAppBar(title: 'Create Account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join Nakshatra',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in your details to create your account',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        labelText: 'First Name',
                        hintText: 'John',
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        hintText: 'Doe',
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'john.doe@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Valid email required'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: '10-digit mobile number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (val) => val == null || val.length < 10
                      ? 'Valid phone required'
                      : null,
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Branch / Store',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppPalette.textLight
                            : AppPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppPalette.surfaceDark
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: authVM.isLoadingBranches
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Loading branches...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<Branch>(
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                ),
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Select Branch',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                value: _selectedBranch,
                                items: authVM.branches.map((Branch branch) {
                                  return DropdownMenuItem<Branch>(
                                    value: branch,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.store_outlined,
                                          size: 18,
                                          color: AppPalette.emerald,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            branch.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? AppPalette.textLight
                                                  : AppPalette.textDark,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedBranch = val;
                                  });
                                },
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'At least 6 characters',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) =>
                      val == null || val.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),
                CustomCheckBoxWidget(
                  value: _agreeTerms,
                  onChanged: (val) =>
                      setState(() => _agreeTerms = val ?? false),
                  title: 'I agree to the Terms of Service & Privacy Policy',
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Create Account',
                  isLoading: authVM.isBusy,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already registered?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppPalette.emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).showProgressOnCenter(isLoading: authVM.isBusy),
    );
  }
}
