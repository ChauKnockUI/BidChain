import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/full_screen_loading.dart';
import '../../widgets/common/custom_toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate username field on change
  void _validateUsername() {
    setState(() {
      _usernameError = Validators.validateUsername(_usernameController.text);
    });
  }

  // Validate password field on change
  void _validatePassword() {
    setState(() {
      _passwordError = Validators.validateLoginPassword(
        _passwordController.text,
      );
    });
  }

  // Validate all fields before submission
  bool _validateForm() {
    _validateUsername();
    _validatePassword();

    return _usernameError == null && _passwordError == null;
  }

  // Handle login with validation
  Future<void> _handleLogin() async {
    // Validate form
    if (!_validateForm()) {
      Toast.error(context, 'Please fix the errors before continuing');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show loading overlay
    LoadingOverlay.show(context, message: 'Signing in...');

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Demo credentials check
      if (username == 'admin' && password == '123456') {
        // Hide loading
        if (mounted) {
          LoadingOverlay.hide();

          // Show success toast
          Toast.success(context, 'Login successful! Welcome back.');

          // Navigate to home
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.go(AppRoutes.home);
          }
        }
      } else {
        // Hide loading
        if (mounted) {
          LoadingOverlay.hide();

          // Show error toast
          Toast.error(context, 'Invalid email or password. Please try again.');
        }
      }
    } catch (e) {
      // Hide loading
      if (mounted) {
        LoadingOverlay.hide();

        // Show error toast
        Toast.error(context, 'An error occurred. Please try again later.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle social login (Google)
  Future<void> _handleGoogleLogin() async {
    Toast.info(context, 'Google Sign-In will be integrated with backend');
  }

  // Handle social login (Facebook)
  Future<void> _handleFacebookLogin() async {
    Toast.info(context, 'Facebook Sign-In will be integrated with backend');
  }

  // Navigate to register page
  void _navigateToRegister() {
    context.push(AppRoutes.register);
  }

  // Navigate to forgot password
  void _navigateToForgotPassword() {
    Toast.info(context, 'Forgot password feature will be available soon');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),

                // Logo and Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to BidChain',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Login Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username Input
                        FormInput(
                          value: _usernameController.text,
                          onChangeText: (value) {
                            _usernameController.text = value;
                            _validateUsername();
                          },
                          label: 'Username',
                          hint: 'Enter your username',
                          error: _usernameError,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        FormInput(
                          value: _passwordController.text,
                          onChangeText: (value) {
                            _passwordController.text = value;
                            _validatePassword();
                          },
                          label: 'Password',
                          hint: 'Enter your password',
                          error: _passwordError,
                          prefixIcon: Icons.lock_outline,
                          secureText: true,
                        ),
                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _navigateToForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        Align(
                          alignment: Alignment.center,
                          child: PrimaryButton(
                            title: 'Sign In',
                            onPress: _handleLogin,
                            loading: _isLoading,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Register Text Link
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: _navigateToRegister,
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                  ),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.grey.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Or continue with',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.grey.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social Login Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _SocialLoginButton(
                                icon: Icons.g_mobiledata_rounded,
                                label: 'Google',
                                onPressed: _handleGoogleLogin,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _SocialLoginButton(
                                icon: Icons.facebook_rounded,
                                label: 'Facebook',
                                onPressed: _handleFacebookLogin,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Demo Credentials
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Demo Credentials',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Username: admin\nPassword: 123456',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.greyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppColors.greyDark),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
