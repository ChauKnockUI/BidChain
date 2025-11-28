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

  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateUsername() {
    setState(() {
      _usernameError = Validators.validateUsername(_usernameController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = Validators.validateLoginPassword(_passwordController.text);
    });
  }

  bool _validateForm() {
    _validateUsername();
    _validatePassword();
    return _usernameError == null && _passwordError == null;
  }

  void _handleLogin() {
    if (!_validateForm()) {
      Toast.error(context, 'Please fix the errors before continuing');
      return;
    }

    // Dispatch login event to BLoC
    context.read<AuthBloc>().add(
          AuthLoginEvent(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _navigateToRegister() {
    context.push(AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    Toast.info(context, 'Forgot password feature will be available soon');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          LoadingOverlay.show(context, message: 'Signing in...');
        } else if (state is AuthSuccessState) {
          LoadingOverlay.hide();
          Toast.success(context, 'Login successful! Welcome back.');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) context.go(AppRoutes.home);
          });
        } else if (state is AuthErrorState) {
          LoadingOverlay.hide();
          Toast.error(context, state.message);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
           color: AppColors.primary,
            
            
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
                      color: AppColors.black,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.black.withOpacity(0.9),
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
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoadingState;
                              return Align(
                                alignment: Alignment.center,
                                child: PrimaryButton(
                                  width: double.infinity,
                                  title: 'Sign In',
                                  onPress: isLoading ? null : _handleLogin,
                                  loading: isLoading,
                                ),
                              );
                            },
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
      ),
    );
  }
}
