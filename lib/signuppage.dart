// =============================================================================
// signuppage.dart - Sign Up Page
// =============================================================================
// This page allows users to create an account for optional features
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'db.dart';
import 'loginpage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Text controllers for input fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Password visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate Email Format
  bool _isValidEmail(String email) {
    // Simple email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate All Fields
  String? _validateFields() {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Check empty fields
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'Please fill in all fields';
    }

    // Username validation
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Email validation
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }

    // Password validation
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Confirm password validation
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // All valid
  }

  Future<void> _handleSignUp() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate fields
    String? validationError = _validateFields();
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      // Check if username already exists
      final existingUsers = await DatabaseHelper.instance.queryAllUsers();
      bool usernameExists = existingUsers.any((u) => u['username'] == username);
      bool emailExists = existingUsers.any((u) => u['email'] == email);

      if (usernameExists) {
        setState(() {
          _errorMessage = 'Username already taken. Please choose another.';
          _isLoading = false;
        });
        return;
      }

      if (emailExists) {
        setState(() {
          _errorMessage = 'Email already registered. Try logging in instead.';
          _isLoading = false;
        });
        return;
      }

      // Create new user
      // Create user data as a Map for database insertion
      Map<String, dynamic> newUser = {
        'username': username,
        'email': email,
        'password': password,
        'displayname': username, // Default display name is username
        'created_at': DateTime.now().toIso8601String(),
      };

      int userId = await DatabaseHelper.instance.insertUser(newUser);

      // Auto-login after signup
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      await prefs.setBool('is_logged_in', true);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Account created successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF388E3C),
          ),
        );

        // Navigate to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      debugPrint('Signup error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B263B),
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
              // Header
              _buildHeader(),

              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null) _buildErrorMessage(),

              // Username field
              _buildInputField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Choose a username',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              // Email field
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Password field
              _buildInputField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a password (min 6 characters)',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Confirm password field
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Sign up button
              _buildSignUpButton(),

              const SizedBox(height: 16),

              // Skip option
              _buildSkipButton(),

              const SizedBox(height: 32),

              // Login link
              _buildLoginLink(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
            child: Text('✨', style: TextStyle(fontSize: 28)),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE0E0E0),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        const Text(
          'Sign up to backup your progress and join the community leaderboard.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF778DA9),
            height: 1.5,
          ),
        ),
      ],
    );
  }

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
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF778DA9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF415A77)),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            prefixIcon: Icon(icon, color: const Color(0xFF778DA9), size: 22),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF778DA9),
                size: 22,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
          'Create Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Continue without account',
          style: TextStyle(color: Color(0xFF778DA9), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Go back to login page
          Navigator.pop(context);
        },
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(fontSize: 14, color: Color(0xFF778DA9)),
              ),
              TextSpan(
                text: 'Log In',
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