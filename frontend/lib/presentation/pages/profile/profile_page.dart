import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_routes.dart';
import '../../widgets/common/secondary_button.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // When logout happens, navigate to login
        if (state is AuthInitialState) {
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccessState) {
            final user = state.user;
            return Scaffold(
              backgroundColor: AppColors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors.greyLight,
                              backgroundImage:
                                  user.avatar != null && user.avatar!.isNotEmpty
                                  ? NetworkImage(user.avatar!) as ImageProvider
                                  : null,
                              child: user.avatar == null || user.avatar!.isEmpty
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 45,
                                      color: AppColors.accent,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    context.push(AppRoutes.editProfile),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        user.username,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Location display
                      if (user.city != null || user.country != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              SizedBox(width: 4),
                              Text(
                                [
                                  user.ward,
                                  user.district,
                                  user.city,
                                ].whereType<String>().join(', '),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'About',
                              style: AppTextStyles.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              user.bio?.isNotEmpty == true
                                  ? user.bio!
                                  : user.fullName.isNotEmpty
                                  ? user.fullName
                                  : 'No bio',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Address section
                      if (user.address != null && user.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address',
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.greyLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      color: AppColors.accent,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        user.address!,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistic',
                              style: AppTextStyles.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 14),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              childAspectRatio: 1.3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              children: [
                                _buildStat(
                                  Icons.gavel_rounded,
                                  '0',
                                  'Auctions',
                                ),
                                _buildStat(
                                  Icons.local_offer_rounded,
                                  '0',
                                  'Bids',
                                ),
                                _buildStat(
                                  Icons.emoji_events_rounded,
                                  '0',
                                  'Won',
                                ),
                                _buildStat(
                                  Icons.percent_rounded,
                                  '0%',
                                  'Success',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SecondaryButton(
                          title: 'Logout Account',
                          icon: Icons.logout,
                          onPress: () => _showLogoutConfirmDialog(context),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(const AuthLogoutEvent());
              },
              child: Text(
                'Logout',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppColors.grey),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
