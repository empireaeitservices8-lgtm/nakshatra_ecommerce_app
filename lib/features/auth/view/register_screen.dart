import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_checkbox_widget.dart';
import '../view_model/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';

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
  bool _agreeTerms = false;
  bool _obscurePassword = true;

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
    if (!_agreeTerms) {
      context.showSnackBar('Please agree to terms and privacy policy', isError: true);
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Account created successfully!');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      context.showSnackBar(authVM.errorMessage ?? 'Registration failed', isError: true);
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
                  'Fill in your details to create your enterprise account',
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
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        hintText: 'Doe',
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                  validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  hintText: '10-digit mobile number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (val) => val == null || val.length < 10 ? 'Valid phone required' : null,
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
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),
                CustomCheckBoxWidget(
                  value: _agreeTerms,
                  onChanged: (val) => setState(() => _agreeTerms = val ?? false),
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
                    Text("Already registered?", style: TextStyle(color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: AppPalette.emerald, fontWeight: FontWeight.bold),
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
