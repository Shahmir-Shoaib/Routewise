import 'package:flutter/material.dart';
import '../../core/contants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/validation_helper.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _nameError = ValidationHelper.getNameError(value);
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _emailError = ValidationHelper.getEmailError(value);
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _passwordError = ValidationHelper.getPasswordError(value);
    });
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _handleSignup(AuthProvider authProvider) async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final success = await authProvider.signup(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final maxWidth = ResponsiveHelper.getMaxWidth(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getHeadlineMediumSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join RouteWise and plan your trips smartly",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodyLargeSize(context),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Form Fields Container
                  _buildFormField(
                    context,
                    _nameController,
                    "Full Name",
                    "Enter your name",
                    Icons.person,
                    _nameError,
                    _validateName,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    context,
                    _emailController,
                    "Email",
                    "Enter your email",
                    Icons.email,
                    _emailError,
                    _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    context,
                    _passwordController,
                    "Password",
                    "Create a password",
                    _isPasswordHidden,
                    () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                    _passwordError,
                    _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    context,
                    _confirmPasswordController,
                    "Confirm Password",
                    "Confirm your password",
                    _isConfirmPasswordHidden,
                    () {
                      setState(() {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      });
                    },
                    _confirmPasswordError,
                    _validateConfirmPassword,
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Column(
                        children: [
                          if (authProvider.errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error,
                                      color: AppColors.danger),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                          color: AppColors.danger),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: authProvider.isLoading ? "" : "Sign Up",
                              isLoading: authProvider.isLoading,
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => _handleSignup(authProvider),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context,
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    String? error,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        errorText: error,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? Colors.red : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2E5BFF),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    TextEditingController controller,
    String label,
    String hint,
    bool isHidden,
    VoidCallback toggleHidden,
    String? error,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: controller,
      obscureText: isHidden,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isHidden ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleHidden,
        ),
        errorText: error,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? AppColors.danger : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
