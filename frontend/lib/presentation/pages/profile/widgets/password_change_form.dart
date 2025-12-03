import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/common/form_input.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/custom_toast.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/auth/auth_event.dart';

class PasswordChangeForm extends StatefulWidget {
  const PasswordChangeForm({super.key});

  @override
  State<PasswordChangeForm> createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  late TextEditingController _currentCtrl;
  late TextEditingController _newCtrl;
  late TextEditingController _confirmCtrl;

  String _currentErr = '';
  String _newErr = '';
  String _confirmErr = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentCtrl = TextEditingController();
    _newCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _changePassword() {
    setState(() {
      _currentErr = _currentCtrl.text.isEmpty ? 'Required' : '';
      _newErr = _newCtrl.text.isEmpty
          ? 'Required'
          : (_newCtrl.text.length < 8 ? 'Min 8 chars' : '');
      _confirmErr = _confirmCtrl.text != _newCtrl.text ? 'Must match' : '';
    });

    if (_currentErr.isEmpty && _newErr.isEmpty && _confirmErr.isEmpty) {
      setState(() => _isLoading = true);
      context.read<AuthBloc>().add(
        AuthChangePasswordEvent(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState && state.message.contains('Password')) {
          setState(() => _isLoading = false);
          _currentCtrl.clear();
          _newCtrl.clear();
          _confirmCtrl.clear();
          Toast.show(
            context,
            message: 'Password changed!',
            type: ToastType.success,
          );
        } else if (state is AuthErrorState) {
          setState(() => _isLoading = false);
          Toast.show(context, message: state.message, type: ToastType.error);
        }
      },
      child: Column(
        children: [
          FormInput(
            label: 'Current Password',
            value: _currentCtrl.text,
            onChangeText: (v) {
              _currentCtrl.text = v;
              if (_currentErr.isNotEmpty) setState(() => _currentErr = '');
            },
            error: _currentErr,
            secureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          SizedBox(height: 16),
          FormInput(
            label: 'New Password',
            value: _newCtrl.text,
            onChangeText: (v) {
              _newCtrl.text = v;
              if (_newErr.isNotEmpty) setState(() => _newErr = '');
            },
            error: _newErr,
            secureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          SizedBox(height: 16),
          FormInput(
            label: 'Confirm Password',
            value: _confirmCtrl.text,
            onChangeText: (v) {
              _confirmCtrl.text = v;
              if (_confirmErr.isNotEmpty) setState(() => _confirmErr = '');
            },
            error: _confirmErr,
            secureText: true,
            prefixIcon: Icons.lock_outline,
          ),
          SizedBox(height: 24),
          PrimaryButton(
            title: 'Change Password',
            loading: _isLoading,
            onPress: _changePassword,
          ),
        ],
      ),
    );
  }
}
