import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/custom_toast.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';
import '../../../core/utils/validators.dart';
import 'widgets/avatar_picker.dart';
import 'widgets/location_picker.dart';
import 'widgets/bio_input.dart';
import 'widgets/password_change_form.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  String _usernameErr = '';
  String _fullNameErr = '';
  String _emailErr = '';
  String _phoneErr = '';

  // Location & Bio fields
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedAddress;
  String? _selectedBio;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccessState) {
      final user = state.user;
      _usernameCtrl = TextEditingController(text: user.username);
      _fullNameCtrl = TextEditingController(text: user.fullName);
      _emailCtrl = TextEditingController(text: user.email);
      _phoneCtrl = TextEditingController(text: user.momoPhone ?? '');

      // Initialize location & bio
      _selectedCountry = user.country;
      _selectedCity = user.city;
      _selectedDistrict = user.district;
      _selectedAddress = user.address;
      _selectedBio = user.bio;
    } else {
      _usernameCtrl = TextEditingController();
      _fullNameCtrl = TextEditingController();
      _emailCtrl = TextEditingController();
      _phoneCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _usernameErr = Validators.validateUsername(_usernameCtrl.text) ?? '';
      _fullNameErr = Validators.validateFullName(_fullNameCtrl.text) ?? '';
      _emailErr = Validators.validateEmail(_emailCtrl.text) ?? '';
      _phoneErr = '';
    });

    if (_usernameErr.isEmpty && _fullNameErr.isEmpty && _emailErr.isEmpty) {
      context.read<AuthBloc>().add(
        AuthUpdateProfileEvent(
          fullName: _fullNameCtrl.text,
          username: _usernameCtrl.text,
          email: _emailCtrl.text,
          phoneNumber: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
          country: _selectedCountry,
          city: _selectedCity,
          district: _selectedDistrict,
          address: _selectedAddress,
          bio: _selectedBio,
        ),
      );
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change Password',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update your password to keep your account secure',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Password form inside dialog
                  PasswordChangeForm(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState && state.message.contains('updated')) {
          Toast.show(
            context,
            message: 'Profile updated!',
            type: ToastType.success,
          );
          context.pop();
        } else if (state is AuthErrorState) {
          Toast.show(context, message: state.message, type: ToastType.error);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.accent),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Profile Photo',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            AvatarPicker(),
            SizedBox(height: 32),
            Text(
              'Personal Information',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FormInput(
              label: 'Username',
              value: _usernameCtrl.text,
              onChangeText: (v) {
                _usernameCtrl.text = v;
                if (_usernameErr.isNotEmpty) setState(() => _usernameErr = '');
              },
              error: _usernameErr,
              hint: 'Username',
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: 16),
            FormInput(
              label: 'Full Name',
              value: _fullNameCtrl.text,
              onChangeText: (v) {
                _fullNameCtrl.text = v;
                if (_fullNameErr.isNotEmpty) setState(() => _fullNameErr = '');
              },
              error: _fullNameErr,
              hint: 'Full name',
              prefixIcon: Icons.badge_outlined,
            ),
            SizedBox(height: 16),
            FormInput(
              label: 'Email',
              value: _emailCtrl.text,
              onChangeText: (v) {
                _emailCtrl.text = v;
                if (_emailErr.isNotEmpty) setState(() => _emailErr = '');
              },
              error: _emailErr,
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
            SizedBox(height: 16),
            FormInput(
              label: 'Phone Number',
              value: _phoneCtrl.text,
              onChangeText: (v) => _phoneCtrl.text = v,
              error: _phoneErr,
              hint: 'Phone',
              prefixIcon: Icons.phone_outlined,
            ),
            SizedBox(height: 32),
            Text(
              'Location & Bio',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            LocationPicker(
              initialCountry: _selectedCountry,
              initialCity: _selectedCity,
              initialDistrict: _selectedDistrict,
              initialAddress: _selectedAddress,
              onLocationChanged: (country, city, district, address) {
                setState(() {
                  _selectedCountry = country;
                  _selectedCity = city;
                  _selectedDistrict = district;
                  _selectedAddress = address;
                });
              },
            ),
            SizedBox(height: 16),
            BioInput(
              initialBio: _selectedBio,
              onBioChanged: (bio) {
                setState(() {
                  _selectedBio = bio;
                });
              },
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            PrimaryButton(title: 'Save Changes', onPress: _save),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
