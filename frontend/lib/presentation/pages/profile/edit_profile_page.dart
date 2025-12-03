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
import 'widgets/password_change_form.dart';
import 'widgets/location_picker.dart';
import 'widgets/bio_input.dart';

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
  String? _selectedWard;
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
      _selectedWard = user.ward;
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
          ward: _selectedWard,
          address: _selectedAddress,
          bio: _selectedBio,
        ),
      );
    }
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
              initialWard: _selectedWard,
              initialAddress: _selectedAddress,
              onLocationChanged: (country, city, district, ward, address) {
                setState(() {
                  _selectedCountry = country;
                  _selectedCity = city;
                  _selectedDistrict = district;
                  _selectedWard = ward;
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
            Text(
              'Security',
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            PasswordChangeForm(),
            SizedBox(height: 32),
            PrimaryButton(title: 'Save Changes', onPress: _save),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
