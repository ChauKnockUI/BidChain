import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../bloc/auction_list/auction_list_bloc.dart';
import '../../bloc/auction_list/auction_list_event.dart';
import '../../bloc/auction_list/auction_list_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/auction/auction_card.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuctionListBloc>().add(const LoadAuctions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: CustomAppBar(
        title: 'Active Auctions',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.black,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          if (state is AuctionListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuctionListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuctionListBloc>().add(const LoadAuctions());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AuctionListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AuctionListBloc>().add(const RefreshAuctions());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.auctions.length,
                itemBuilder: (context, index) {
                  final auction = state.auctions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AuctionCard(
                      auctionId: auction.auctionId,
                      title: auction.title,
                      imageUrl: auction.images.isNotEmpty
                          ? auction.images.first
                          : null,
                      currentBid: auction.formattedCurrentPrice,
                      timeLeft: _calculateTimeLeft(auction.endTime),
                      bidCount: auction.bidCount,
                      sellerName: auction.sellerName,
                      sellerImageUrl: null,
                      onTap: () {
                        context.go(
                          '${AppRoutes.auctionDetail}/${auction.auctionId}',
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _calculateTimeLeft(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Ended';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
