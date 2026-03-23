// =============================================================================
// loginpage.dart - Login Page
// This login page is used for OPTIONAL features
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signuppage.dart';
import 'main.dart';
import 'db.dart';

// LoginPage Widget
class LoginPage extends StatefulWidget {
  final VoidCallback? onSkip;

  const LoginPage({Key? key, this.onSkip}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for text input fields
  // These let us read what the user types
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Toggle for showing/hiding password
  bool _obscurePassword = true;

  // Loading state for login button
  bool _isLoading = false;

  // Error message to display (null if no error)
  String? _errorMessage;

  @override
  void dispose() {
    // Clean up controllers when widget is removed
    // This prevents memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle Login
  Future<void> _handleLogin() async {
    // Clear any previous error
    setState(() {
      _errorMessage = null;
    });

    // Get input values and trim whitespace
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Input Validation
    // Check if fields are empty before attempting login
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Database Query
      final userMaps = await DatabaseHelper.instance.queryAllUsers();

      // Find matching user
      Map<String, dynamic>? matchedUser;
      for (var userMap in userMaps) {
        if (userMap['username'] == username && userMap['password'] == password) {
          matchedUser = userMap;
          break;
        }
      }

      if (matchedUser != null) {
        // Successful Login
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', matchedUser['id']);
        await prefs.setString('username', matchedUser['username']);
        await prefs.setString('email', matchedUser['email'] ?? '');
        await prefs.setBool('is_logged_in', true);

        // Navigate to main app
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else {
        // Failed Login
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      }
    } catch (e) {
      // Handle any database errors
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      // Hide loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent keyboard from pushing content up too much
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1B263B),

      // App bar with back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF778DA9)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header section
              _buildHeader(),

              const SizedBox(height: 40),

              // Error message (if any)
              if (_errorMessage != null) _buildErrorMessage(),

              // Username field
              _buildInputField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Enter your username',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              // Password field
              _buildInputField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 12),

              // Forgot password link
              _buildForgotPasswordLink(),

              const SizedBox(height: 32),

              // Login button
              _buildLoginButton(),

              const SizedBox(height: 16),

              // Skip login option
              _buildSkipButton(),

              const SizedBox(height: 32),

              // Sign up link
              _buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFF415A77),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🔐', style: TextStyle(fontSize: 28)),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE0E0E0),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle explaining why login is optional
        const Text(
          'Log in to sync your progress across devices and join the community leaderboard.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF778DA9),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Error Message
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input Field
  // Reusable input field widget with consistent styling.
  // Supports both regular text and password input.
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        // Text field
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF415A77)),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),

            // Icon on the left
            prefixIcon: Icon(icon, color: const Color(0xFF778DA9), size: 22),

            // Show/hide password toggle for password fields
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF778DA9),
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            )
                : null,

            // Border styling
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF415A77)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Forgot Password Link
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset feature coming soon!'),
              backgroundColor: Color(0xFF415A77),
            ),
          );
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFF4FC3F7),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Login Button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Disable button visually when loading
          disabledBackgroundColor: const Color(0xFF4FC3F7).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        )
            : const Text(
          'Log In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Skip Login Button
  // Allows users to continue without logging in.
  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          // If a skip callback was provided, call it
          if (widget.onSkip != null) {
            widget.onSkip!();
          } else {
            // Otherwise just go back
            Navigator.pop(context);
          }
        },
        child: const Text(
          'Continue without account',
          style: TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Sign Up Link
  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Navigate to sign up page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        },
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF778DA9),
                ),
              ),
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// HELPER FUNCTION - Check if user is logged in
Future<bool> isUserLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
}

// HELPER FUNCTION - Get current user ID
Future<int?> getCurrentUserId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('user_id');
}

// HELPER FUNCTION - Log out user
Future<void> logoutUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_id');
  await prefs.remove('username');
  await prefs.remove('email');
  await prefs.setBool('is_logged_in', false);
}