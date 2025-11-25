import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/full_screen_loading.dart';
import '../../widgets/common/custom_toast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _password = '';
  String _confirmPassword = '';

  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isLoading = false;
  bool _agreeToTerms = false;

  void _handleRegister() async {
    // Clear previous errors
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate terms acceptance
    if (!_agreeToTerms) {
      Toast.error(context, 'Please agree to Terms & Conditions');
      return;
    }

    // Validate all fields
    final usernameValidation = Validators.validateUsername(_username);
    final passwordValidation = Validators.validatePassword(_password);
    final confirmPasswordValidation = Validators.validateConfirmPassword(
      _confirmPassword,
      _password,
    );

    if (usernameValidation != null ||
        passwordValidation != null ||
        confirmPasswordValidation != null) {
      setState(() {
        _usernameError = usernameValidation;
        _passwordError = passwordValidation;
        _confirmPasswordError = confirmPasswordValidation;
      });
      return;
    }

    setState(() => _isLoading = true);
    LoadingOverlay.show(context, message: 'Creating your account...');

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Demo credentials check (remove in production)
      if (_username.trim() == 'admin') {
        throw Exception('Username already exists');
      }

      // Simulate successful registration
      print('Registration successful:');
      print('Username: $_username');
      print('Password: ${_password.replaceAll(RegExp(r'.'), '*')}');

      if (mounted) {
        LoadingOverlay.hide();
        setState(() => _isLoading = false);

        // Show success message
        Toast.success(context, 'Account created successfully!');

        // Navigate to login after short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide();
        setState(() => _isLoading = false);

        Toast.error(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _handleGoogleRegister() async {
    Toast.info(context, 'Google Sign Up - Coming soon!');
  }

  void _handleFacebookRegister() async {
    Toast.info(context, 'Facebook Sign Up - Coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.accent.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  IconButton(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Create Account',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign up to start bidding',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Username Input
                  FormInput(
                    label: 'Username',
                    value: _username,
                    onChangeText: (value) {
                      setState(() {
                        _username = value;
                        _usernameError = null;
                      });
                    },
                    error: _usernameError,
                    hint: 'Enter your username (min 3 characters)',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 20),

                  // Password Input
                  FormInput(
                    label: 'Password',
                    value: _password,
                    onChangeText: (value) {
                      setState(() {
                        _password = value;
                        _passwordError = null;
                      });
                    },
                    error: _passwordError,
                    hint: 'Create a strong password',
                    secureText: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password Input
                  FormInput(
                    label: 'Confirm Password',
                    value: _confirmPassword,
                    onChangeText: (value) {
                      setState(() {
                        _confirmPassword = value;
                        _confirmPasswordError = null;
                      });
                    },
                    error: _confirmPasswordError,
                    hint: 'Re-enter your password',
                    secureText: true,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 24),

                  // Terms & Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                          activeColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _agreeToTerms = !_agreeToTerms);
                          },
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  Align(
                    alignment: Alignment.center,
                    child: PrimaryButton(
                      title: 'Create Account',
                      onPress: _isLoading ? null : _handleRegister,
                      loading: _isLoading,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider with "Or continue with"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.greyLight,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.greyLight,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          title: 'Google',
                          onPress: _handleGoogleRegister,
                          icon: Icons.g_mobiledata,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SecondaryButton(
                          title: 'Facebook',
                          onPress: _handleFacebookRegister,
                          icon: Icons.facebook,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Already have account link
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
