import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class AuctionCard extends StatelessWidget {
  final String auctionId;
  final String title;
  final String currentBid;
  final String endTime;
  final int bidCount;
  final VoidCallback? onTap;

  const AuctionCard({
    super.key,
    required this.auctionId,
    required this.title,
    required this.currentBid,
    required this.endTime,
    required this.bidCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: AppColors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4),
                    const SizedBox(height: 6),
                    Text('$currentBid • $bidCount bids', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(endTime, style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning)),
            ],
          ),
        ),
      ),
    );
  }
}
