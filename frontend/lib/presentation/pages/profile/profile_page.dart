import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/custom_toast.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../domain/entities/user_entity.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Avatar state
  Uint8List? _avatarBytes;
  String? _avatarUrl;
  bool _hasAvatar = false;

  // Change password dialog state
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  String currentPasswordError = '';
  String newPasswordError = '';
  String confirmPasswordError = '';
  bool isChangingPassword = false;

  // Conversion rate: 1 ETH = 50,000,000 VND
  double ethToVnd(double eth) => eth * 50000000;

  String formatVnd(double vnd) {
    return '${vnd.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )} đ';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Toast.show(
      context,
      message: 'Đã copy vào clipboard!',
      type: ToastType.success,
    );
  }

  // Avatar Management Methods
  void _pickAvatar() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

<<<<<<< Updated upstream
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((event) {
=======
      setState(() {
        _isUploadingAvatar = true;
      });

      // Read file as bytes for web compatibility
      final bytes = await image.readAsBytes();
      final filename = image.name;

      // Upload to backend (Cloudinary)
      final updatedUser = await _userRepository.uploadAndUpdateAvatar(
        bytes,
        filename,
      );

      // Update auth state with new user data
      if (mounted) {
        context.read<AuthBloc>().add(UpdateUserEvent(updatedUser));
        
>>>>>>> Stashed changes
        setState(() {
          _avatarBytes = reader.result as Uint8List;
          _hasAvatar = true;
        });
        Toast.show(
          context,
          message: 'Avatar uploaded successfully!',
          type: ToastType.success,
        );
      });
    });
  }

  void _changeAvatar() {
    _pickAvatar();
  }

  void _deleteAvatar() {
    setState(() {
      _avatarBytes = null;
      _avatarUrl = null;
      _hasAvatar = false;
    });
    Toast.show(
      context,
      message: 'Avatar deleted successfully!',
      type: ToastType.success,
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Avatar Options',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            if (!_hasAvatar)
              ListTile(
                leading: Icon(Icons.upload, color: AppColors.accent),
                title: Text('Upload Avatar', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar();
                },
              ),
            if (_hasAvatar) ...[
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.accent),
                title: Text('Change Avatar', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _changeAvatar();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text(
                  'Delete Avatar',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAvatar();
                },
              ),
            ],
            const SizedBox(height: 10),
            SecondaryButton(
              title: 'Cancel',
              onPress: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccessState) {
          final user = state.user;
          return _buildContent(user);
        } else if (state is AuthLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Fallback for testing or if not logged in (should redirect)
          return const Scaffold(
            body: Center(child: Text("Please login to view profile")),
          );
        }
      },
    );
  }

  Widget _buildContent(UserEntity user) {
    final double availableEth = user.balanceEth - user.lockedEth;
    // Mock stats for now as they are not in UserEntity yet
    final int totalAuctions = 12;
    final int totalBids = 45;
    final int auctionsWon = 8;
    final double successRate = totalBids > 0 ? (auctionsWon / totalBids * 100) : 0;

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 20),
            _buildWalletBalanceCard(user, availableEth),
            const SizedBox(height: 20),
            _buildUserInformationCard(user),
            const SizedBox(height: 20),
            _buildStatisticsGrid(totalAuctions, totalBids, auctionsWon, successRate),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Profile Header Section
  Widget _buildProfileHeader(UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Edit Button
          GestureDetector(
            onTap: _showAvatarOptions,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                    image: _avatarBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_avatarBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarBytes == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: AppColors.accent,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(
                      _hasAvatar ? Icons.edit : Icons.add_a_photo,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            user.username,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: user.role == 'ADMIN' 
                  ? AppColors.error.withOpacity(0.9)
                  : AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role,
              style: AppTextStyles.labelMedium.copyWith(
                color: user.role == 'ADMIN' ? AppColors.white : AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Member since
          Text(
            'Member since ${formatDate(user.createdAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Wallet Balance Card
  Widget _buildWalletBalanceCard(UserEntity user, double availableEth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                'Wallet Balance',
                style: AppTextStyles.h4.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Total Balance
          _buildBalanceRow(
            'Total Balance',
            user.balanceEth,
            ethToVnd(user.balanceEth),
            AppColors.accent,
            isBold: true,
          ),
          const Divider(height: 24),
          // Locked Balance
          _buildBalanceRow(
            'Locked',
            user.lockedEth,
            ethToVnd(user.lockedEth),
            AppColors.warning,
          ),
          const Divider(height: 24),
          // Available Balance
          _buildBalanceRow(
            'Available',
            availableEth,
            ethToVnd(availableEth),
            AppColors.success,
          ),
          const SizedBox(height: 20),
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  title: 'Deposit',
                  icon: Icons.add_circle_outline,
                  height: 44,
                  onPress: () {
                    Toast.show(
                      context,
                      message: 'Deposit feature coming soon!',
                      type: ToastType.info,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  title: 'Withdraw',
                  icon: Icons.remove_circle_outline,
                  height: 44,
                  onPress: () {
                    Toast.show(
                      context,
                      message: 'Withdraw feature coming soon!',
                      type: ToastType.info,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
    String label,
    double eth,
    double vnd,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${eth.toStringAsFixed(4)} ETH',
              style: AppTextStyles.bodyLarge.copyWith(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            Text(
              formatVnd(vnd),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // User Information Card
  Widget _buildUserInformationCard(UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.accent, size: 24),
              const SizedBox(width: 8),
              Text(
                'User Information',
                style: AppTextStyles.h4.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.badge_outlined, 'Full Name', user.fullName),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.account_balance_wallet_outlined,
            'Wallet Address',
            shortenAddress(user.walletAddress),
            onTap: () => copyToClipboard(user.walletAddress),
            showCopyIcon: true,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.numbers, 'Last Nonce', user.lastNonce.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
    bool showCopyIcon = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showCopyIcon)
          IconButton(
            icon: Icon(Icons.copy, size: 18, color: AppColors.accent),
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  // Statistics Grid
  Widget _buildStatisticsGrid(int totalAuctions, int totalBids, int auctionsWon, double successRate) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          Icons.gavel,
          totalAuctions.toString(),
          'Auctions',
          AppColors.tertiary,
        ),
        _buildStatCard(
          Icons.local_offer,
          totalBids.toString(),
          'Bids',
          AppColors.accent,
        ),
        _buildStatCard(
          Icons.emoji_events,
          auctionsWon.toString(),
          'Won',
          AppColors.warning,
        ),
        _buildStatCard(
          Icons.percent,
          '${successRate.toStringAsFixed(0)}%',
          'Success',
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          title: 'Edit Profile',
          icon: Icons.edit_outlined,
          onPress: () {
            Toast.show(
              context,
              message: 'Edit Profile coming soon!',
              type: ToastType.info,
            );
          },
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          title: 'Change Password',
          icon: Icons.lock_outline,
          onPress: _showChangePasswordDialog,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          title: 'View My Auctions',
          icon: Icons.gavel,
          onPress: () {
            Toast.show(
              context,
              message: 'My Auctions coming soon!',
              type: ToastType.info,
            );
          },
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          title: 'View My Bids',
          icon: Icons.local_offer,
          onPress: () {
            Toast.show(
              context,
              message: 'My Bids coming soon!',
              type: ToastType.info,
            );
          },
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          title: 'Transaction History',
          icon: Icons.history,
          onPress: () {
            Toast.show(
              context,
              message: 'Transaction History coming soon!',
              type: ToastType.info,
            );
          },
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          title: 'Logout',
          icon: Icons.logout,
          onPress: () {
            Toast.show(
              context,
              message: 'Logout coming soon!',
              type: ToastType.warning,
            );
          },
        ),
      ],
    );
  }

  // Change Password Dialog
  void _showChangePasswordDialog() {
    // Reset state
    setState(() {
      currentPassword = '';
      newPassword = '';
      confirmPassword = '';
      currentPasswordError = '';
      newPasswordError = '';
      confirmPasswordError = '';
      isChangingPassword = false;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Đổi mật khẩu',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormInput(
                    label: 'Current Password',
                    value: currentPassword,
                    onChangeText: (value) {
                      setDialogState(() {
                        currentPassword = value;
                        currentPasswordError = '';
                      });
                    },
                    error: currentPasswordError,
                    hint: 'Enter current password',
                    secureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 16),
                  FormInput(
                    label: 'New Password',
                    value: newPassword,
                    onChangeText: (value) {
                      setDialogState(() {
                        newPassword = value;
                        newPasswordError = '';
                      });
                    },
                    error: newPasswordError,
                    hint: 'Enter new password',
                    secureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 16),
                  FormInput(
                    label: 'Confirm Password',
                    value: confirmPassword,
                    onChangeText: (value) {
                      setDialogState(() {
                        confirmPassword = value;
                        confirmPasswordError = '';
                      });
                    },
                    error: confirmPasswordError,
                    hint: 'Confirm new password',
                    secureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                ],
              ),
            ),
            actions: [
              SecondaryButton(
                title: 'Cancel',
                onPress: () => Navigator.of(context).pop(),
                width: 100,
                height: 44,
              ),
              PrimaryButton(
                title: 'Confirm',
                loading: isChangingPassword,
                onPress: () => _handleChangePassword(setDialogState),
                width: 100,
                height: 44,
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleChangePassword(StateSetter setDialogState) {
    // Validate
    bool hasError = false;

    setDialogState(() {
      // Check current password
      if (currentPassword.isEmpty) {
        currentPasswordError = 'Current password is required';
        hasError = true;
      } else if (currentPassword.length < 6) {
        currentPasswordError = 'Password must be at least 6 characters';
        hasError = true;
      }

      // Check new password
      if (newPassword.isEmpty) {
        newPasswordError = 'New password is required';
        hasError = true;
      } else if (newPassword.length < 6) {
        newPasswordError = 'Password must be at least 6 characters';
        hasError = true;
      } else if (newPassword == currentPassword) {
        newPasswordError = 'New password must be different from current';
        hasError = true;
      }

      // Check confirm password
      if (confirmPassword.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
        hasError = true;
      } else if (confirmPassword != newPassword) {
        confirmPasswordError = 'Passwords do not match';
        hasError = true;
      }
    });

    if (hasError) return;

    // Mock API call
    setDialogState(() {
      isChangingPassword = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setDialogState(() {
        isChangingPassword = false;
      });

      Navigator.of(context).pop();

      Toast.show(
        context,
        message: 'Password changed successfully!',
        type: ToastType.success,
      );
    });
  }
}
