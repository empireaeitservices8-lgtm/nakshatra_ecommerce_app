import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class SignUpScreen extends StatefulWidget {
  static const String path = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        city.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final response = await cartProvider.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully! Logging in..."),
            backgroundColor: Color(0xFF2E513D),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Auto-login
        final loginRes = await cartProvider.login(email, password);
        if (mounted) {
          if (loginRes['status'] == 'success') {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Registration failed. Please try again."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

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
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildWhiteInputField(
                            hint: "First Name",
                            icon: Icons.person_outline,
                            controller: _firstNameCtrl,
                            inputType: TextInputType.name,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildWhiteInputField(
                            hint: "Last Name",
                            icon: Icons.person_outline,
                            controller: _lastNameCtrl,
                            inputType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Mobile Number",
                      icon: Icons.phone_android_outlined,
                      controller: _phoneCtrl,
                      inputType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                      controller: _emailCtrl,
                      inputType: TextInputType.emailAddress,
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
                      controller: _passwordCtrl,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onPasswordToggle: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInputField(
                      hint: "Confirm Password",
                      icon: Icons.lock_outline,
                      controller: _confirmPasswordCtrl,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onPasswordToggle: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    cartProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white),
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
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: onPasswordToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildMainButton(String text) {
    return Material(
      color: Colors.transparent, // Required for InkWell to show ripple
      child: InkWell(
        onTap: _handleSignUp,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
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
