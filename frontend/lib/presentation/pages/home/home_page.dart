import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: Text(
          'BidChain',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.accent),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explore and bid on amazing items',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.waving_hand_rounded,
                    color: AppColors.white,
                    size: 40,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.gavel_rounded,
                  label: 'Browse Auctions',
                  color: AppColors.tertiary,
                  onTap: () => context.go(AppRoutes.auctionList),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create Auction',
                  color: AppColors.accent,
                  onTap: () => context.go(AppRoutes.createAuction),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'My Wallet',
                  color: AppColors.secondary,
                  onTap: () => context.go(AppRoutes.wallet),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.person_rounded,
                  label: 'My Profile',
                  color: AppColors.accentDark,
                  onTap: () => context.go(AppRoutes.profile),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            Text(
              'Recent Activity',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No recent activity',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< Updated upstream
=======

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'BidChain',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        // TODO: Re-enable NotificationBloc when implemented
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.black,
          ),
          onPressed: () {
            context.push('/notifications');
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search auctions...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.black),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          // Add "All" category at the beginning
          final allCategories = [
            {'id': null, 'name': 'All', 'icon': Icons.apps},
            ...state.categories.map(
              (cat) => {
                'id': cat.id,
                'name': cat.name,
                'icon': _getCategoryIcon(cat.name),
              },
            ),
          ];

          return SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = _selectedCategoryId == category['id'];

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < allCategories.length - 1 ? 8 : 0,
                  ),
                  child: CategoryChip(
                    label: category['name'] as String,
                    icon: category['icon'] as IconData?,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category['id'] as String?;
                      });
                    },
                  ),
                );
              },
            ),
          );
        } else if (state is CategoryLoading) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else {
          // Show default categories if loading fails
          return SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                CategoryChip(
                  label: 'All',
                  icon: Icons.apps,
                  isSelected: _selectedCategoryId == null,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('điện tử') ||
        name.contains('điện thoại') ||
        name.contains('laptop')) {
      return Icons.devices;
    } else if (name.contains('thời trang') ||
        name.contains('quần áo') ||
        name.contains('giày')) {
      return Icons.checkroom;
    } else if (name.contains('nghệ thuật') ||
        name.contains('tranh') ||
        name.contains('tác phẩm')) {
      return Icons.palette;
    } else if (name.contains('đồ cổ') || name.contains('sưu tầm')) {
      return Icons.stars;
    } else if (name.contains('xe') ||
        name.contains('phương tiện') ||
        name.contains('ô tô') ||
        name.contains('xe máy')) {
      return Icons.directions_car;
    } else if (name.contains('thủ công') ||
        name.contains('mỹ nghệ') ||
        name.contains('handmade') ||
        name.contains('gốm')) {
      return Icons.handyman;
    } else if (name.contains('sách') || name.contains('book')) {
      return Icons.book;
    } else if (name.contains('khác')) {
      return Icons.category;
    }

    return Icons.category; // default
  }

  String _calculateTimeLeft(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Ended';
    }

    if (difference.inDays > 0) {
      final hours = difference.inHours % 24;
      return '${difference.inDays}d ${hours}h';
    } else if (difference.inHours > 0) {
      final minutes = difference.inMinutes % 60;
      return '${difference.inHours}h ${minutes}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
>>>>>>> Stashed changes
}
