import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/di/injection_container.dart';
import '../../bloc/auction/auction_bloc.dart';
import '../../bloc/auction/auction_event.dart';
import '../../bloc/auction/auction_state.dart';
import '../../widgets/auction/auction_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.getAuctionBloc()..add(GetAuctions()),
      child: Scaffold(
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
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.accent,
              ),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
          ],
        ),
        body: BlocBuilder<AuctionBloc, AuctionState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AuctionBloc>().add(RefreshAuctions());
              },
              color: AppColors.accent,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          _buildWelcomeSection(),
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
                          _buildQuickActionsGrid(context),
                          const SizedBox(height: 24),

                          // Live Auctions Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Live Auctions',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.auctionList),
                                child: Text(
                                  'View All',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Auction Grid or Loading/Error/Empty State
                  if (state is AuctionLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is AuctionError)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AuctionBloc>().add(
                                  RefreshAuctions(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is AuctionLoaded)
                    if (state.auctions.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No active auctions found',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final auction = state.auctions[index];
                            return AuctionCard(
                              auctionId: auction.auctionId,
                              title: auction.title,
                              imageUrl: auction.images.isNotEmpty
                                  ? auction.images.first
                                  : null,
                              currentBid: auction.formattedCurrentPrice,
                              timeLeft: _calculateTimeLeft(auction.endTime),
                              bidCount: auction.bidCount,
                              sellerName: auction.sellerName,
                              onTap: () {
                                context.go(
                                  '${AppRoutes.auctionDetail}/${auction.auctionId}',
                                );
                              },
                            );
                          }, childCount: state.auctions.length),
                        ),
                      ),

                  // Bottom Padding
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
          const Icon(
            Icons.waving_hand_rounded,
            color: AppColors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
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
          icon: Icons.gavel_rounded,
          label: 'My activity',
          color: AppColors.tertiary,
          onTap: () => context.go(AppRoutes.myActivity),
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
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
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
                child: Icon(icon, size: 32, color: color),
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

  /// Calculate time left until auction ends
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
}
