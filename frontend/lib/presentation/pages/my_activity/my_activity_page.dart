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
      appBar: CustomAppBar(
        title: 'Hoạt động của tôi',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.accent,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Column(
        children: [
          // Custom TabBar
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.grey,
              labelStyle: AppTextStyles.labelLarge,
              unselectedLabelStyle: AppTextStyles.labelLarge,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Đấu giá của tôi'),
                Tab(text: 'Bid của tôi'),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: BlocBuilder<MyActivityBloc, MyActivityState>(
              builder: (context, state) {
                if (state is MyActivityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MyActivityError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đã xảy ra lỗi',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<MyActivityBloc>().add(
                                const LoadMyAuctions(),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is MyActivityLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // My Auctions Tab
                      MyAuctionsTab(
                        auctions: state.auctions,
                        onRefresh: () {
                          context.read<MyActivityBloc>().add(
                            const RefreshMyActivity(),
                          );
                        },
                        onAuctionTap: (auctionId) {
                          // Navigate to auction detail
                          context.go('/auction-detail/$auctionId');
                        },
                      ),

                      // My Bids Tab
                      MyBidsTab(
                        bids: state.bids,
                        onRefresh: () {
                          context.read<MyActivityBloc>().add(
                            const RefreshMyActivity(),
                          );
                        },
                        onBidTap: (auctionId) {
                          // Navigate to auction detail
                          context.go('/auction-detail/$auctionId');
                        },
                      ),
                    ],
                  );
                }

                // Initial state
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
