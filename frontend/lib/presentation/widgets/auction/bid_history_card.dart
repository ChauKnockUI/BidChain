import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../domain/entities/bid_entity.dart';
import '../user/user_avatar.dart';

class BidHistoryCard extends StatelessWidget {
  final BidEntity bid;
  final bool isHighest;

  const BidHistoryCard({super.key, required this.bid, this.isHighest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighest
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighest
              ? AppColors.success
              : AppColors.secondary.withValues(alpha: 0.5),
          width: isHighest ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          UserAvatar(name: bid.userName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      bid.userName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isHighest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Cao nhất',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(bid.createdAt, locale: 'vi'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            bid.formattedAmount,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isHighest ? AppColors.success : AppColors.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
