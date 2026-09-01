import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/auth_viewmodel.dart';
import 'otp_verification_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  static const String path = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await authVM.login(email, password);
    if (!mounted) return;

    if (success) {
      context.showSnackBar('Welcome back!');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      context.showSnackBar(authVM.errorMessage ?? 'Login failed. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: buildAppBar(title: 'Sign In', showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppPalette.emerald.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 48,
                      color: AppPalette.emerald,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.emeraldDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your devices, users, and account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 36),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email / Username',
                  hintText: 'Enter your email or username',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) {
                    if (val == null || val.length < 4) return 'Password must be at least 4 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Sign In',
                  isLoading: authVM.isBusy,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, OtpVerificationScreen.routeName);
                      },
                      child: const Text(
                        'Sign in with OTP',
                        style: TextStyle(color: AppPalette.emerald, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RegisterScreen.routeName);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.bold),
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
