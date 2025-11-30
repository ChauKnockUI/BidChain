import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auction_detail/auction_detail_bloc.dart';
import '../../bloc/auction_detail/auction_detail_event.dart';
import '../../bloc/auction_detail/auction_detail_state.dart';
import '../../widgets/auction/bid_history_card.dart';
import '../../widgets/auction/countdown_timer.dart';
import '../../widgets/auction/image_gallery.dart';
import '../../widgets/auction/place_bid_dialog.dart';
import '../../widgets/auction/seller_info_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/status_badge.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;

  const AuctionDetailPage({super.key, required this.auctionId});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to load auction details when page initializes
    context.read<AuctionDetailBloc>().add(
      LoadAuctionDetail(auctionId: widget.auctionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuctionDetailBloc, AuctionDetailState>(
      listener: (context, state) {
        if (state is BidPlaced) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Refresh user balance after successful bid
          context.read<AuthBloc>().add(const AuthCheckStatusEvent());
        } else if (state is BidError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Chi tiết đấu giá',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: AppColors.accent,
              onPressed: () => context.go(AppRoutes.home),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                color: AppColors.accent,
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton:
              state is AuctionDetailLoaded && state.auction.isActive
              ? FloatingActionButton.extended(
                  onPressed: () => _showPlaceBidDialog(context, state.auction),
                  backgroundColor: AppColors.accent,
                  icon: const Icon(Icons.gavel, color: AppColors.white),
                  label: Text(
                    'Đặt giá',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AuctionDetailState state) {
    if (state is AuctionDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AuctionDetailError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi',
                style: AppTextStyles.h4.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<AuctionDetailBloc>().add(
                    LoadAuctionDetail(auctionId: widget.auctionId),
                  );
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AuctionDetailLoaded ||
        state is BidPlacing ||
        state is BidPlaced ||
        state is BidError) {
      final auction = state is AuctionDetailLoaded
          ? state.auction
          : state is BidPlacing
          ? state.auction
          : state is BidPlaced
          ? state.auction
          : (state as BidError).auction;

      return RefreshIndicator(
        onRefresh: () async {
          context.read<AuctionDetailBloc>().add(
            RefreshAuctionDetail(auctionId: widget.auctionId),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Image Gallery
            ImageGallery(images: auction.images),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Row(
                    children: [
                      StatusBadge(status: auction.status),
                      const Spacer(),
                      CountdownTimer(endTime: auction.endTime),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    auction.title,
                    style: AppTextStyles.h2.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    auction.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seller Info
                  SellerInfoCard(
                    sellerName: auction.sellerName,
                    sellerEmail: auction.sellerEmail,
                  ),
                  const SizedBox(height: 20),

                  // Price Information
                  _buildPriceInfo(auction),
                  const SizedBox(height: 24),

                  // Bid History
                  _buildBidHistory(auction),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildPriceInfo(auction) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin giá',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PriceItem(
                    label: 'Giá khởi điểm',
                    value: auction.formattedStartPrice,
                    color: AppColors.grey,
                  ),
                ),
                Expanded(
                  child: _PriceItem(
                    label: 'Giá hiện tại',
                    value: auction.formattedCurrentPrice,
                    color: AppColors.tertiary,
                    isHighlight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriceItem(
                    label: 'Bước giá',
                    value: auction.formattedStepPrice,
                    color: AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _PriceItem(
                    label: 'Số lượt đấu giá',
                    value: '${auction.bidCount}',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidHistory(auction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử đấu giá (${auction.bidCount})',
          style: AppTextStyles.h4.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: 12),
        if (auction.bids.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: AppColors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có lượt đấu giá nào',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auction.bids.length,
            itemBuilder: (context, index) {
              final bid = auction.bids[index];
              return BidHistoryCard(bid: bid, isHighest: index == 0);
            },
          ),
      ],
    );
  }

  void _showPlaceBidDialog(BuildContext context, auction) {
    showDialog(
      context: context,
      builder: (dialogContext) => PlaceBidDialog(
        currentPrice: auction.currentPriceVnd,
        stepPrice: auction.stepPriceVnd,
        formattedCurrentPrice: auction.formattedCurrentPrice,
        formattedStepPrice: auction.formattedStepPrice,
        onPlaceBid: (amount) {
          context.read<AuctionDetailBloc>().add(
            PlaceBid(auctionId: widget.auctionId, amountVnd: amount),
          );
        },
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isHighlight;

  const _PriceItem({
    required this.label,
    required this.value,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlight ? 18 : null,
          ),
        ),
      ],
    );
  }
}
