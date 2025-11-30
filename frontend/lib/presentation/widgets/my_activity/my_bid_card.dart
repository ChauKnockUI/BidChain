import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../domain/entities/my_bid_entity.dart';
import '../common/status_badge.dart';

class MyBidCard extends StatelessWidget {
  final MyBidEntity bid;
  final VoidCallback? onTap;

  const MyBidCard({super.key, required this.bid, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = bid.images.isNotEmpty;
    final timeRemaining = _getTimeRemaining(bid.endTime);
    final isWinning =
        bid.myBidAmount >= bid.currentPrice && bid.status == 'ACTIVE';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
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
                      bid.images.first,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: StatusBadge(status: bid.status),
                    ),
                    if (bid.isWinner)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 14,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Thắng',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                    left: 8,
                    child: StatusBadge(status: bid.status),
                  ),
                  if (bid.isWinner)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Thắng',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    bid.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.accent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bid comparison
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá của tôi',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bid.formattedMyBid,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isWinning
                                    ? AppColors.success
                                    : AppColors.accent,
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
                              bid.formattedCurrentPrice,
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

                  // Time and Status
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
                      if (isWinning && bid.status == 'ACTIVE')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Đang thắng',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else if (!isWinning && bid.status == 'ACTIVE')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Bị vượt giá',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
