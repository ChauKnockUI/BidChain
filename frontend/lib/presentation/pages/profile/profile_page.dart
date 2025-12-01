import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/form_input.dart';
import '../../widgets/common/custom_toast.dart';
import '../../../core/utils/validators.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/datasources/remote/user_remote_datasource.dart';
import '../../../core/network/dio_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserRepository _userRepository;

  // Loading states
  bool _isLoadingStats = false;
  bool _isUploadingAvatar = false;

  // Statistics data
  int _totalAuctions = 0;
  int _totalBids = 0;
  int _auctionsWon = 0;
  double _successRate = 0.0;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository(UserRemoteDataSourceImpl(DioClient()));
    _loadUserStatistics();
  }

  // Load user statistics from API
  Future<void> _loadUserStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final auctions = await _userRepository.getUserAuctions();
      final bids = await _userRepository.getUserBids();

      // Calculate statistics
      final wonBids = bids.where((bid) => bid['is_winner'] == true).toList();

      setState(() {
        _totalAuctions = auctions.length;
        _totalBids = bids.length;
        _auctionsWon = wonBids.length;
        _successRate = _totalBids > 0 ? (_auctionsWon / _totalBids * 100) : 0.0;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      if (mounted) {
        Toast.show(
          context,
          message: 'Failed to load statistics: $e',
          type: ToastType.error,
        );
      }
    }
  }

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
    return '${vnd.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
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
  Future<void> _pickAndUploadAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      // Read image bytes (works on both web and mobile)
      final bytes = await image.readAsBytes();
      final fileName = image.name;

      // Upload to backend (Cloudinary)
      final updatedUser = await _userRepository.uploadAndUpdateAvatarBytes(
        bytes,
        fileName,
      );

      // Update auth state with new user data
      if (mounted) {
        context.read<AuthBloc>().add(UpdateUserEvent(updatedUser));

        setState(() {
          _isUploadingAvatar = false;
        });

        Toast.show(
          context,
          message: 'Avatar uploaded successfully!',
          type: ToastType.success,
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });

      if (mounted) {
        Toast.show(
          context,
          message: 'Failed to upload avatar: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _deleteAvatar() async {
    try {
      setState(() {
        _isUploadingAvatar = true;
      });

      final updatedUser = await _userRepository.deleteAvatar();

      if (mounted) {
        context.read<AuthBloc>().add(UpdateUserEvent(updatedUser));

        setState(() {
          _isUploadingAvatar = false;
        });

        Toast.show(
          context,
          message: 'Avatar deleted successfully!',
          type: ToastType.success,
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });

      if (mounted) {
        Toast.show(
          context,
          message: 'Failed to delete avatar: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _showAvatarOptions(bool hasAvatar) {
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Avatar Options',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            if (!hasAvatar)
              ListTile(
                leading: Icon(Icons.upload, color: AppColors.accent),
                title: Text('Upload Avatar', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar();
                },
              ),
            if (hasAvatar) ...[
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.accent),
                title: Text('Change Avatar', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadAvatar();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text(
                  'Delete Avatar',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitialState) {
          // User logged out, navigate to login page
          context.go(AppRoutes.login);
        } else if (state is AuthSuccessState) {
          if (state.message.isNotEmpty &&
              !state.message.startsWith('Login') &&
              !state.message.startsWith('Registration')) {
            if (state.message.contains('Error')) {
              Toast.error(context, state.message);
            } else {
              Toast.success(context, state.message);
            }
          }
        } else if (state is AuthErrorState) {
          Toast.error(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
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
      ),
    );
  }

  Widget _buildContent(UserEntity user) {
    final double availableEth = user.balanceEth - user.lockedEth;
    final bool hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,

        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.accent),
            onPressed: _loadUserStatistics,
            tooltip: 'Refresh statistics',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserStatistics,
        color: AppColors.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(user, hasAvatar),
              const SizedBox(height: 20),
              _buildWalletBalanceCard(user, availableEth),
              const SizedBox(height: 20),
              _buildUserInformationCard(user),
              const SizedBox(height: 20),
              _buildStatisticsGrid(),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Header Section
  Widget _buildProfileHeader(UserEntity user, bool hasAvatar) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Edit Button
          GestureDetector(
            onTap: () => _showAvatarOptions(hasAvatar),
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: hasAvatar
                        ? DecorationImage(
                            image: NetworkImage(user.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasAvatar
                      ? Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: AppColors.accent,
                        )
                      : null,
                ),
                if (_isUploadingAvatar)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      hasAvatar ? Icons.edit : Icons.add_a_photo,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Username
          Text(
            user.username,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 10),
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: user.role == 'ADMIN'
                  ? AppColors.error.withOpacity(0.9)
                  : AppColors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              user.role,
              style: AppTextStyles.labelMedium.copyWith(
                color: user.role == 'ADMIN'
                    ? AppColors.white
                    : AppColors.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Member since
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Text(
                'Member since ${formatDate(user.createdAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Wallet Balance Card
  Widget _buildWalletBalanceCard(UserEntity user, double availableEth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Wallet Balance',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Total Balance
          _buildBalanceRow(
            'Total Balance',
            user.balanceEth,
            ethToVnd(user.balanceEth),
            AppColors.accent,
            isBold: true,
          ),
          const Divider(height: 28),
          // Locked Balance
          _buildBalanceRow(
            'Locked',
            user.lockedEth,
            ethToVnd(user.lockedEth),
            AppColors.warning,
          ),
          const Divider(height: 28),
          // Available Balance
          _buildBalanceRow(
            'Available',
            availableEth,
            ethToVnd(availableEth),
            AppColors.success,
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
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // User Information Card
  Widget _buildUserInformationCard(UserEntity user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'User Information',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.badge_outlined, 'Full Name', user.fullName),
          const SizedBox(height: 18),
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.account_balance_wallet_outlined,
            'Wallet Address',
            shortenAddress(user.walletAddress),
            onTap: () => copyToClipboard(user.walletAddress),
            showCopyIcon: true,
          ),
          const SizedBox(height: 18),
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
        Icon(icon, size: 22, color: AppColors.grey),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showCopyIcon)
          IconButton(
            icon: Icon(Icons.copy, size: 20, color: AppColors.accent),
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  // Statistics Grid
  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4, // Increased from 1.3 to give more height
      children: [
        _buildStatCard(
          Icons.gavel,
          _isLoadingStats ? '...' : _totalAuctions.toString(),
          'Auctions',
          AppColors.tertiary,
        ),
        _buildStatCard(
          Icons.local_offer,
          _isLoadingStats ? '...' : _totalBids.toString(),
          'Bids',
          AppColors.accent,
        ),
        _buildStatCard(
          Icons.emoji_events,
          _isLoadingStats ? '...' : _auctionsWon.toString(),
          'Won',
          AppColors.warning,
        ),
        _buildStatCard(
          Icons.percent,
          _isLoadingStats ? '...' : '${_successRate.toStringAsFixed(0)}%',
          'Success',
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: color), // Reduced from 28 to 26
          ),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              // Use FittedBox to auto-scale text
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize:
                      22, // Fixed size instead of h3 (which might be too large)
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Fixed smaller size for labels
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
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
          onPress: () => _showEditProfileDialog(context),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          title: 'Change Password',
          icon: Icons.lock_outline,
          onPress: _showChangePasswordDialog,
        ),

        const SizedBox(height: 14),
        SecondaryButton(
          title: 'Logout',
          icon: Icons.logout,
          onPress: _showLogoutDialog,
        ),
      ],
    );
  }

  // Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Logout',
          style: AppTextStyles.h4.copyWith(color: AppColors.accent),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
        ),
        actions: [
          SecondaryButton(
            title: 'Cancel',
            onPress: () => Navigator.of(context).pop(),
            width: 100,
            height: 44,
          ),
          PrimaryButton(
            title: 'Logout',
            onPress: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthLogoutEvent());
            },
            width: 100,
            height: 44,
            backgroundColor: AppColors.error,
          ),
        ],
      ),
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
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccessState) {
                if (state.message.contains('Password changed successfully')) {
                  setDialogState(() {
                    isChangingPassword = false;
                  });
                  Navigator.of(context).pop();
                  Toast.show(
                    context,
                    message: state.message,
                    type: ToastType.success,
                  );
                } else if (state.message.contains('Error')) {
                  setDialogState(() {
                    isChangingPassword = false;
                  });
                  Toast.show(
                    context,
                    message: state.message,
                    type: ToastType.error,
                  );
                }
              } else if (state is AuthErrorState) {
                setDialogState(() {
                  isChangingPassword = false;
                });
                Toast.show(
                  context,
                  message: state.message,
                  type: ToastType.error,
                );
              }
            },
            child: AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
            ),
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
      } else if (currentPassword.length < 8) {
        currentPasswordError = 'Password must be at least 8 characters';
        hasError = true;
      }

      // Check new password
      if (newPassword.isEmpty) {
        newPasswordError = 'New password is required';
        hasError = true;
      } else if (newPassword.length < 8) {
        newPasswordError = 'Password must be at least 8 characters';
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

    // Dispatch event to Bloc
    setDialogState(() {
      isChangingPassword = true;
    });

    context.read<AuthBloc>().add(
      AuthChangePasswordEvent(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    // Listen to Bloc state changes is handled in the main build method
    // We just need to close the dialog if successful, but since we can't easily listen inside this function without a BlocListener in the dialog,
    // we might need to rely on the main page listener to close the dialog or show toast.
    // However, to close the dialog from here, we need to know when it's done.
    // A common pattern is to wait for the state change or use a Completer, but with Bloc, we usually react to state.

    // For now, let's just close the dialog and let the main page show the toast.
    // BUT, we want to keep the dialog open if there is an error.
    // So we should wrap the dialog content in a BlocListener.

    // Actually, the best way is to wrap the Dialog content in a BlocListener.
    // Let's modify the showDialog part instead.

    // For this step, I will just dispatch the event.
    // I will modify the showDialog to include BlocListener in the next step.

    // Wait, I can't leave this function broken.
    // I'll remove the mock delay and just dispatch.
    // The UI update (loading) is local to the dialog.
    // The Bloc will emit states.

    // Let's just dispatch here.
    context.read<AuthBloc>().add(
      AuthChangePasswordEvent(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    // Get current user info from Bloc state
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccessState) return;

    final user = authState.user;
    String fullName = user.fullName;
    String username = user.username;
    String email = user.email;

    String fullNameError = '';
    String usernameError = '';
    String emailError = '';
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit Profile',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormInput(
                    label: 'Full Name',
                    value: fullName,
                    onChangeText: (value) {
                      setDialogState(() {
                        fullName = value;
                        fullNameError = '';
                      });
                    },
                    error: fullNameError,
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  FormInput(
                    label: 'Username',
                    value: username,
                    onChangeText: (value) {
                      setDialogState(() {
                        username = value;
                        usernameError = '';
                      });
                    },
                    error: usernameError,
                    hint: 'Enter username',
                    prefixIcon: Icons.alternate_email,
                  ),
                  const SizedBox(height: 16),
                  FormInput(
                    label: 'Email',
                    value: email,
                    onChangeText: (value) {
                      setDialogState(() {
                        email = value;
                        emailError = '';
                      });
                    },
                    error: emailError,
                    hint: 'Enter email',
                    prefixIcon: Icons.email_outlined,
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
                title: 'Save',
                loading: isUpdating,
                onPress: () {
                  // Validate
                  final fullNameValidation = Validators.validateFullName(
                    fullName,
                  );
                  final usernameValidation = Validators.validateUsername(
                    username,
                  );
                  final emailValidation = Validators.validateEmail(email);

                  setDialogState(() {
                    fullNameError = fullNameValidation ?? '';
                    usernameError = usernameValidation ?? '';
                    emailError = emailValidation ?? '';
                  });

                  if (fullNameValidation != null ||
                      usernameValidation != null ||
                      emailValidation != null) {
                    return;
                  }

                  Navigator.of(context).pop();

                  context.read<AuthBloc>().add(
                    AuthUpdateProfileEvent(
                      fullName: fullName,
                      username: username,
                      email: email,
                    ),
                  );
                },
                width: 100,
                height: 44,
              ),
            ],
          );
        },
      ),
    );
  }
}
