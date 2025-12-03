import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../common/optimized_image.dart';
import '../user/user_avatar.dart';

class AuctionCard extends StatelessWidget {
  /// ID cuộc đấu giá
  final String auctionId;

  /// Tên cuộc đấu giá
  final String title;

  /// URL ảnh thumbnail (tùy chọn)
  final String? imageUrl;

  /// Giá hiện tại / Highest Bid
  final String currentBid;

  /// Thời gian còn lại (format: "2h 30m" hoặc "2d 5h")
  final String timeLeft;

  /// Số lượt bid
  final int bidCount;

  /// Tên người bán (dùng cho avatar)
  final String sellerName;
  final String? status;

  /// URL ảnh avatar người bán (tùy chọn)
  final String? sellerImageUrl;

  /// Callback khi tap vào card
  final VoidCallback? onTap;

  const AuctionCard({
    super.key,
    required this.auctionId,
    required this.title,
    this.imageUrl,
    required this.currentBid,
    required this.timeLeft,
    required this.bidCount,
    required this.sellerName,
    this.sellerImageUrl,
    this.onTap,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Image with Fixed Aspect Ratio
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
                child: AspectRatio(
                  aspectRatio: 1.1, // Slightly landscape
                  child: hasImage
                      ? OptimizedImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          memCacheHeight: 400,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        )
                      : _buildPlaceholder(),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Price & Bids Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Giá cao nhất',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentBid,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.tertiary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$bidCount bids',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Divider
                      const Divider(
                        color: AppColors.tertiary,
                        thickness: 1,
                        height: 8,
                      ),

                      // Time Left & Seller
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    timeLeft,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Seller Avatar
                          UserAvatar(
                            name: sellerName,
                            imageUrl: sellerImageUrl,
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget placeholder khi không có ảnh
  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.greyLight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
}
