import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/dio_client.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_back_button.dart';
import '../../widgets/text/expandable_text.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userEmail;

  const PublicProfilePage({
    super.key,
    required this.userId,
    this.userName,
    this.userEmail,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  late Future<UserModel> _userFuture;
  late Future<Map<String, dynamic>> _statsFuture;
  final UserRepository _userRepository = InjectionContainer.getUserRepository();
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _userFuture = _userRepository.getUserById(widget.userId);
    _statsFuture = _fetchUserStats();
  }

  Future<Map<String, dynamic>> _fetchUserStats() async {
    try {
      final response = await _dioClient.get('/user/${widget.userId}/stats');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {'auctions': 0, 'bids': 0, 'wins': 0, 'successRate': 0};
    } catch (e) {
      return {'auctions': 0, 'bids': 0, 'wins': 0, 'successRate': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Thông tin người bán',
        leading: const CustomBackButton(color: AppColors.accent),
      ),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải thông tin',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No user data'));
          }

          final user = snapshot.data!;
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.greyLight,
                        backgroundImage: user.avatar != null &&
                                user.avatar!.isNotEmpty
                            ? NetworkImage(user.avatar!) as ImageProvider
                            : null,
                        child: user.avatar == null || user.avatar!.isEmpty
                            ? Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: AppColors.accent,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Username
                    Text(
                      user.username,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Location
                    if (user.city != null || user.country != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
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
                    const SizedBox(height: 20),

                    // About Section
                    if (user.bio?.isNotEmpty == true ||
                        user.fullName.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About',
                              style: AppTextStyles.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ExpandableInlineText(
                              text: user.bio?.isNotEmpty == true
                                  ? user.bio!
                                  : user.fullName.isNotEmpty
                                      ? user.fullName
                                      : 'No bio available',
                              maxLines: 3,
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.5,
                                color: AppColors.grey,
                              ),
                              readMoreStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Contact Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin liên hệ',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        color: AppColors.accent, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tên đầy đủ',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user.fullName.isNotEmpty
                                                ? user.fullName
                                                : user.username,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.email_outlined,
                                        color: AppColors.accent, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Email',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user.email,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _statsFuture,
                            builder: (context, statsSnapshot) {
                              final stats = statsSnapshot.data ??
                                  {'auctions': 0, 'bids': 0, 'wins': 0, 'successRate': 0};

                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1.4,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                children: [
                                  _buildStat(
                                    Icons.gavel_rounded,
                                    '${stats['auctions'] ?? 0}',
                                    'Auctions',
                                  ),
                                  _buildStat(
                                    Icons.local_offer_rounded,
                                    '${stats['bids'] ?? 0}',
                                    'Bids',
                                  ),
                                  _buildStat(
                                    Icons.emoji_events_rounded,
                                    '${stats['wins'] ?? 0}',
                                    'Won',
                                  ),
                                  _buildStat(
                                    Icons.percent_rounded,
                                    '${stats['successRate'] ?? 0}%',
                                    'Success',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
