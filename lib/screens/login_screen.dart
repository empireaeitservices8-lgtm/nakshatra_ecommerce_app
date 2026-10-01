import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';
import '../utils/app_palette.dart';
import '../utils/extensions.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_button_widget.dart';
import '../widgets/app_custom_text_field.dart';
import '../widgets/custom_app_bar.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  static const String path = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Mode: 0 = Phone + OTP Login (Primary), 1 = Email + Password Login
  int _loginMode = 0;

  // Phone + OTP controllers & states
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  bool _otpSent = false;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  // Email + Password controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authVM.requestOtp(phone);
    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      _startResendTimer();

      final otpCode = authVM.lastSentOtp;
      final otpMsg = otpCode != null ? ' (OTP: $otpCode)' : '';
      ToastHelper.showSuccessToast(
        context,
        'OTP sent successfully to $phone$otpMsg',
      );

      if (otpCode != null && _otpController.text.isEmpty) {
        _otpController.text = otpCode;
      }
    } else {
      ToastHelper.showErrorToast(
        context,
        authVM.errorMessage ?? 'Failed to send OTP. Please check your number.',
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.verifyOtp(phone, otp);
    if (!mounted) return;

    if (success) {
      ToastHelper.showSuccessToast(context, 'Login successful! Welcome to Nakshatra.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainScreen.path,
        (route) => false,
      );
    } else {
      ToastHelper.showErrorToast(
        context,
        authVM.errorMessage ?? 'Invalid OTP code. Please try again.',
      );
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await authVM.login(email, password);
    if (!mounted) return;

    if (success) {
      ToastHelper.showSuccessToast(context, 'Welcome back!');
      Navigator.pushReplacementNamed(context, MainScreen.path);
    } else {
      ToastHelper.showErrorToast(
        context,
        authVM.errorMessage ?? 'Login failed. Please check your credentials.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: buildAppBar(
        title: _loginMode == 0 ? (_otpSent ? 'Verify OTP' : 'Login') : 'Sign In',
        showBackButton: _otpSent,
        onBackPressed: _otpSent
            ? () {
                setState(() => _otpSent = false);
              }
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Brand Logo / Icon Card
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppPalette.goldDark, AppPalette.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppPalette.goldDark.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.diamond_outlined,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                _loginMode == 0
                    ? (_otpSent ? 'OTP Verification' : 'Welcome to Nakshatra')
                    : 'Welcome Back',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _loginMode == 0
                    ? (_otpSent
                        ? 'Enter the 6-digit code sent to +91 ${_phoneController.text}'
                        : 'Enter your phone number to receive a verification OTP')
                    : 'Sign in with your email and password to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),

              // Content based on Mode
              if (_loginMode == 0) ...[
                if (!_otpSent) _buildPhoneStep(authVM, isDark) else _buildOtpStep(authVM, isDark),
              ] else ...[
                _buildEmailStep(authVM, isDark),
              ],

              const SizedBox(height: 24),

              // Toggle between Phone/OTP and Email Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _loginMode == 0 ? 'Prefer password login?' : 'Prefer OTP login?',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _loginMode = _loginMode == 0 ? 1 : 0;
                        _otpSent = false;
                      });
                    },
                    child: Text(
                      _loginMode == 0 ? 'Sign In with Password' : 'Sign In with Phone & OTP',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.emerald,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RegisterScreen.routeName);
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppPalette.goldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).showProgressOnCenter(isLoading: authVM.isBusy),
    );
  }

  // Step 1: Phone Number Input
  Widget _buildPhoneStep(AuthViewModel authVM, bool isDark) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: '9876543210',
            keyboardType: TextInputType.phone,
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_android_rounded, size: 20, color: AppPalette.emerald),
                  const SizedBox(width: 8),
                  Text(
                    '+91',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 18,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Phone number is required';
              }
              final clean = val.replaceAll(RegExp(r'\D'), '');
              if (clean.length < 10) {
                return 'Please enter a valid 10-digit phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Send OTP',
            isLoading: authVM.isBusy,
            onPressed: _handleSendOtp,
          ),
        ],
      ),
    );
  }

  // Step 2: OTP Input & Verification
  Widget _buildOtpStep(AuthViewModel authVM, bool isDark) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info banner with branch and edit number button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppPalette.surfaceDark : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_iphone_rounded, size: 20, color: AppPalette.emerald),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+91 ${_phoneController.text}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (authVM.lastBranch != null && authVM.lastBranch!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Branch: ${authVM.lastBranch}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppPalette.goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _otpSent = false);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: AppPalette.emerald,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          CustomTextField(
            controller: _otpController,
            labelText: 'One-Time Password (OTP)',
            hintText: 'Enter 4-6 digit OTP',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.pin_outlined, size: 20, color: AppPalette.goldDark),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter the OTP';
              }
              if (val.trim().length < 4) {
                return 'OTP must be at least 4 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          AppButton(
            text: 'Verify & Login',
            isLoading: authVM.isBusy,
            onPressed: _handleVerifyOtp,
          ),
          const SizedBox(height: 16),

          // Resend Timer / Resend Button
          Center(
            child: _resendCountdown > 0
                ? Text(
                    'Resend OTP in ${_resendCountdown}s',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : TextButton.icon(
                    onPressed: authVM.isBusy ? null : _handleSendOtp,
                    icon: const Icon(Icons.refresh_rounded, size: 18, color: AppPalette.emerald),
                    label: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: AppPalette.emerald,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Step 3: Traditional Email + Password
  Widget _buildEmailStep(AuthViewModel authVM, bool isDark) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: 'Email / Username',
            hintText: 'Enter your email or username',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Email is required';
              }
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
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (val) {
              if (val == null || val.length < 4) {
                return 'Password must be at least 4 chars';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Sign In',
            isLoading: authVM.isBusy,
            onPressed: _handleEmailLogin,
          ),
        ],
      ),
    );
  }
}
