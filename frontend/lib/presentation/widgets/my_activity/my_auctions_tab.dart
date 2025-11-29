import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/my_auction_entity.dart';
import '../common/empty_state.dart';
import 'my_auction_card.dart';

class MyAuctionsTab extends StatelessWidget {
  final List<MyAuctionEntity> auctions;
  final VoidCallback onRefresh;
  final Function(String) onAuctionTap;

  const MyAuctionsTab({
    super.key,
    required this.auctions,
    required this.onRefresh,
    required this.onAuctionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) {
      return EmptyState(
        icon: Icons.gavel_outlined,
        title: 'Chưa có đấu giá',
        message:
            'Bạn chưa tạo phiên đấu giá nào.\nHãy tạo phiên đấu giá đầu tiên của bạn!',
        actionLabel: 'Tạo đấu giá',
        onAction: () {
          // Navigate to create auction page
          context.go('/create-auction');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: auctions.length,
        itemBuilder: (context, index) {
          final auction = auctions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MyAuctionCard(
              auction: auction,
              onTap: () => onAuctionTap(auction.id),
            ),
          );
        },
      ),
    );
  }
}
