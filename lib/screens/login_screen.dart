import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class LoginScreen extends StatefulWidget {
  static const String path = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both email and password"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final response = await cartProvider.login(email, password);

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome to Nakshathra, ${cartProvider.userName}!"),
            backgroundColor: const Color(0xFF2E513D),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Login failed. Please check credentials."),
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

          // 3. Content Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes Top, Center, Bottom
                children: [
                  // --- TOP SECTION: LOGO ---
                  Column(
                    children: [
                      const SizedBox(height: 120),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                      ), // Replace with your logo
                      const SizedBox(height: 10),
                    ],
                  ),

                  // --- CENTER SECTION: LOGIN FORM ---
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildWhiteInputField(
                        hint: "Email or Mobile Number",
                        icon: Icons.email_outlined,
                        controller: _emailCtrl,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 20),
                      cartProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : _buildMainButton("Login"),
                    ],
                  ),

                  // --- BOTTOM SECTION: SOCIAL & SIGNUP ---
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "New to Nakshathra? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/signup'),
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
                ],
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildMainButton(String text) {
    return Material(
      color: Colors.transparent, // Required for InkWell to show ripple
      child: InkWell(
        onTap: _handleLogin,
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
