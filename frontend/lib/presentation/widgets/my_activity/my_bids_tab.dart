import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/my_bid_entity.dart';
import '../common/empty_state.dart';
import 'my_bid_card.dart';

class MyBidsTab extends StatelessWidget {
  final List<MyBidEntity> bids;
  final VoidCallback onRefresh;
  final Function(String) onBidTap;

  const MyBidsTab({
    super.key,
    required this.bids,
    required this.onRefresh,
    required this.onBidTap,
  });

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) {
      return EmptyState(
        icon: Icons.local_offer_outlined,
        title: 'Chưa có bid',
        message:
            'Bạn chưa tham gia đấu giá nào.\nHãy tìm kiếm và đặt giá cho sản phẩm yêu thích!',
        actionLabel: 'Khám phá đấu giá',
        onAction: () {
          // Navigate to auction list
          context.go('/auctions');
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
        itemCount: bids.length,
        itemBuilder: (context, index) {
          final bid = bids[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MyBidCard(bid: bid, onTap: () => onBidTap(bid.auctionId)),
          );
        },
      ),
    );
  }
}
