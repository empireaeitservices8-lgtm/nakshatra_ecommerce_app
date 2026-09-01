import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/auth_viewmodel.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const String routeName = '/otp-verification';

  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      context.showSnackBar('Please enter a valid 10-digit phone number', isError: true);
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.requestOtp(phone);
    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      context.showSnackBar('OTP sent to $phone');
    } else {
      context.showSnackBar(authVM.errorMessage ?? 'Failed to send OTP', isError: true);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length < 4) {
      context.showSnackBar('Please enter a valid OTP', isError: true);
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.verifyOtp(phone, otp);
    if (!mounted) return;

    if (success) {
      context.showSnackBar('Verification successful');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      context.showSnackBar(authVM.errorMessage ?? 'Invalid OTP', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: buildAppBar(title: 'OTP Verification'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppPalette.goldLight.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 48,
                    color: AppPalette.goldDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Phone Verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'Enter the OTP sent to ${_phoneController.text}'
                    : 'We will send an OTP to verify your account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                readOnly: _otpSent,
                prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _otpController,
                  labelText: 'One-Time Password (OTP)',
                  hintText: 'Enter 4-6 digit OTP',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                ),
              ],
              const SizedBox(height: 28),
              if (!_otpSent)
                AppButton(
                  text: 'Send OTP',
                  isLoading: authVM.isBusy,
                  onPressed: _handleRequestOtp,
                )
              else
                AppButton(
                  text: 'Verify & Continue',
                  isLoading: authVM.isBusy,
                  onPressed: _handleVerifyOtp,
                ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _handleRequestOtp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(color: AppPalette.emerald, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ).showProgressOnCenter(isLoading: authVM.isBusy),
    );
  }
}
