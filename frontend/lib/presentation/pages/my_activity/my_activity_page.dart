import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../bloc/my_activity/my_activity_bloc.dart';
import '../../bloc/my_activity/my_activity_event.dart';
import '../../bloc/my_activity/my_activity_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/my_activity/my_auctions_tab.dart';
import '../../widgets/my_activity/my_bids_tab.dart';

class MyActivityPage extends StatefulWidget {
  const MyActivityPage({super.key});

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data when page opens
    context.read<MyActivityBloc>().add(const LoadMyAuctions());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'My Activity',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.accent,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Column(
        children: [
          // Modern Custom TabBar with Pill Design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.grey,
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel, size: 18),
                        SizedBox(width: 8),
                        Text('My Bids'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 18),
                        SizedBox(width: 8),
                        Text('My Auctions'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TabBarView
          Expanded(
            child: BlocBuilder<MyActivityBloc, MyActivityState>(
              builder: (context, state) {
                if (state is MyActivityLoading) {
                  return _buildLoadingState();
                }

                if (state is MyActivityError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is MyActivityLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      MyBidsTab(
                        bids: state.bids,
                        onRefresh: () {
                          context.read<MyActivityBloc>().add(
                            const RefreshMyActivity(),
                          );
                        },
                        onBidTap: (auctionId) {
                          context.go('/auction-detail/$auctionId');
                        },
                      ),

                      // Participated Auctions Tab
                      MyAuctionsTab(
                        auctions: state.auctions,
                        onRefresh: () {
                          context.read<MyActivityBloc>().add(
                            const RefreshMyActivity(),
                          );
                        },
                        onAuctionTap: (auctionId) {
                          context.go('/auction-detail/$auctionId');
                        },
                      ),
                    ],
                  );
                }

                return _buildLoadingState();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Modern loading state with shimmer effect
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải dữ liệu...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced error state with better visuals
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon with Circle Background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            
            // Error Title
            Text(
              'Đã Xảy Ra Lỗi',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Error Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Retry Button with Modern Style
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<MyActivityBloc>().add(
                    const LoadMyAuctions(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Thử Lại',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}