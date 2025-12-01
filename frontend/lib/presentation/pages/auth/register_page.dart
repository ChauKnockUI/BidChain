import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/full_screen_loading.dart';
import '../../widgets/common/custom_toast.dart';
import '../../widgets/common/custom_back_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _fullNameError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _agreeToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateUsername() {
    setState(() {
      _usernameError = Validators.validateUsername(_usernameController.text);
    });
  }

  void _validateEmail() {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
    });
  }

  void _validateFullName() {
    setState(() {
      final fullName = _fullNameController.text.trim();
      if (fullName.isEmpty) {
        _fullNameError = 'Full name is required';
      } else if (fullName.length < 3) {
        _fullNameError = 'Full name must be at least 3 characters';
      } else {
        _fullNameError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = Validators.validatePassword(_passwordController.text);
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = Validators.validateConfirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });
  }

  bool _validateForm() {
    _validateUsername();
    _validateEmail();
    _validateFullName();
    _validatePassword();
    _validateConfirmPassword();

    return _usernameError == null &&
        _emailError == null &&
        _fullNameError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  void _handleRegister() {
    // Validate terms acceptance
    if (!_agreeToTerms) {
      Toast.error(context, 'Please agree to Terms & Conditions');
      return;
    }

    // Validate form
    if (!_validateForm()) {
      Toast.error(context, 'Please fix the errors before continuing');
      return;
    }

    // Dispatch register event to BLoC
    context.read<AuthBloc>().add(
          AuthRegisterEvent(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          LoadingOverlay.show(context, message: 'Creating your account...');
        } else if (state is AuthSuccessState) {
          LoadingOverlay.hide();
          Toast.success(context, 'Account created successfully!');
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) context.go(AppRoutes.login);
          });
        } else if (state is AuthErrorState) {
          LoadingOverlay.hide();
          Toast.error(context, state.message);
        }
      },
      child: Scaffold(
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
                    CustomBackButton(
                      onPressed: () => context.go(AppRoutes.login),
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

                    // Full Name Input
                    FormInput(
                      label: 'Full Name',
                      value: _fullNameController.text,
                      onChangeText: (value) {
                        _fullNameController.text = value;
                        _validateFullName();
                      },
                      error: _fullNameError,
                      hint: 'Enter your full name',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 20),

                    // Email Input
                    FormInput(
                      label: 'Email',
                      value: _emailController.text,
                      onChangeText: (value) {
                        _emailController.text = value;
                        _validateEmail();
                      },
                      error: _emailError,
                      hint: 'Enter your email address',
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 20),

                    // Username Input
                    FormInput(
                      label: 'Username',
                      value: _usernameController.text,
                      onChangeText: (value) {
                        _usernameController.text = value;
                        _validateUsername();
                      },
                      error: _usernameError,
                      hint: 'Choose a username (min 3 characters)',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 20),

                    // Password Input
                    FormInput(
                      label: 'Password',
                      value: _passwordController.text,
                      onChangeText: (value) {
                        _passwordController.text = value;
                        _validatePassword();
                      },
                      error: _passwordError,
                      hint: 'Create a strong password (min 8 characters)',
                      secureText: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password Input
                    FormInput(
                      label: 'Confirm Password',
                      value: _confirmPasswordController.text,
                      onChangeText: (value) {
                        _confirmPasswordController.text = value;
                        _validateConfirmPassword();
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
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoadingState;
                        return Align(
                          alignment: Alignment.center,
                          child: PrimaryButton(
                            title: 'Create Account',
                            onPress: isLoading ? null : _handleRegister,
                            loading: isLoading,
                          ),
                        );
                      },
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
      ),
    );
  }
}
