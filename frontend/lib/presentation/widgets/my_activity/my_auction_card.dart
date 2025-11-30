import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../domain/entities/my_auction_entity.dart';
import '../common/status_badge.dart';

class MyAuctionCard extends StatelessWidget {
  final MyAuctionEntity auction;
  final VoidCallback? onTap;

  const MyAuctionCard({super.key, required this.auction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = auction.images.isNotEmpty;
    final timeRemaining = _getTimeRemaining(auction.endTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      auction.images.first,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: StatusBadge(status: auction.status),
                    ),
                  ],
                ),
              )
            else
              Stack(
                children: [
                  _buildPlaceholder(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatusBadge(status: auction.status),
                  ),
                ],
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    auction.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.accent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prices
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá khởi điểm',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auction.formattedStartPrice,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Giá hiện tại',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auction.formattedCurrentPrice,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Divider
                  Divider(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    thickness: 1,
                    height: 8,
                  ),
                  const SizedBox(height: 10),

                  // Time and Bidder
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeRemaining,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (auction.highestBidder != null) ...[
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          auction.highestBidder!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.tertiary.withValues(alpha: 0.5),
      ),
    );
  }

  String _getTimeRemaining(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Đã kết thúc';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Sắp kết thúc';
    }
  }
}
