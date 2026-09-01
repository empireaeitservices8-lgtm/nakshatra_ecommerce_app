import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../helpers/sp_helper.dart';
import '../helpers/toast_helper.dart';
import '../services/token_manager.dart';

class LoginScreen extends StatefulWidget {
  static const String path = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  void _checkSavedSession() {
    final token = SPHelper.getToken();
    if (token != null && token.isNotEmpty) {
      TokenManager.setToken(token);
      final user = SPHelper.getUser();
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (user != null) {
        authVM.setCurrentUser(user);
      }
      authVM.loadProfile(); // Refresh profile in background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          // 3. Content Layout
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
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                    ), // Replace with your logo
                    const SizedBox(height: 40),

                    // --- CENTER SECTION: LOGIN FORM ---
                    _buildWhiteInputField(
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 15),
                    _buildWhiteInputField(
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onPasswordToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 20),
                    _buildMainButton("Login"),

                    const SizedBox(height: 60),

                    // --- BOTTOM SECTION: SOCIAL & SIGNUP ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New to Nakshathra? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
            vertical: 18,
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
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter email and password'),
                    ),
                  );
                  return;
                }
                final success = await authVM.login(email, password);
                if (success) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ToastHelper.showErrorToast(
                    context,
                    authVM.errorMessage ?? 'Login failed',
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
