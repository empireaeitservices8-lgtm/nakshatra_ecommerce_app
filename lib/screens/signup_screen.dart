import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../helpers/toast_helper.dart';

class SignUpScreen extends StatefulWidget {
  static const String path = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityCtrl.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-Screen Background Image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login5.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),

          // 3. Scrollable Content Layout
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    // --- TOP SECTION: LOGO ---
                    const SizedBox(height: 20),
                    Image.asset('assets/images/logo.png', height: 100),
                    const SizedBox(height: 15),

                    // Title
                    const Text(
                      "Create Luxury Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- CENTER SECTION: SIGN UP FORM ---
                    _buildWhiteInputField(
                      hint: "First Name",
                      icon: Icons.person_outline,
                      inputType: TextInputType.name,
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 15),
                    _buildWhiteInputField(
                      hint: "Last Name",
                      icon: Icons.person_outline,
                      inputType: TextInputType.name,
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Mobile Number",
                      icon: Icons.phone_android_outlined,

                      inputType: TextInputType.phone,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Email Address",
                      icon: Icons.email_outlined,

                      inputType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "City",
                      icon: Icons.location_city_outlined,
                      controller: _cityCtrl,
                      inputType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Password",
                      icon: Icons.lock_outline,

                      isPassword: true,
                      obscureText: _obscurePassword,
                      onPasswordToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Confirm Password",
                      icon: Icons.lock_outline,

                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onPasswordToggle: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 20),

                    authVM.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _buildMainButton("Sign Up"),

                    const SizedBox(height: 20),

                    // --- BOTTOM SECTION: LOGIN LINK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildWhiteInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onPasswordToggle,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.30),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white54),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white54,
                  ),
                  onPressed: onPasswordToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(String text) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Material(
      color: Colors.transparent, // Required for InkWell to show ripple
      child: InkWell(
        onTap: authVM.isLoading
            ? null
            : () async {
                final firstName = _firstNameController.text.trim();
                final lastName = _lastNameController.text.trim();
                final phone = _phoneController.text.trim();
                final email = _emailController.text.trim();
                final city = _cityCtrl.text.trim();
                final password = _passwordController.text.trim();
                final confirmPassword = _confirmPasswordController.text.trim();

                if (firstName.isEmpty ||
                    phone.isEmpty ||
                    email.isEmpty ||
                    city.isEmpty ||
                    password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                final success = await authVM.register(
                  firstName: firstName,
                  lastName: lastName,
                  phone: phone,
                  email: email,
                  password: password,
                  city: city,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Account created successfully! Welcome to Nakshathra.",
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ToastHelper.showErrorToast(
                    context,
                    authVM.errorMessage ?? "Registration failed",
                  );
                }
              },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: authVM.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
