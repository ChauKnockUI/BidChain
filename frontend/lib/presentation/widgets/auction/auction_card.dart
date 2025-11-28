import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
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
    this.status
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: Image.network(
                  imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 160,
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              )
            else
              _buildPlaceholder(),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h4.copyWith(color: AppColors.accent),
                  ),

                  const SizedBox(height: 10),

                  // Highest Bid & Bid Count
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá cao nhất',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentBid,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Số lượt',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$bidCount bids',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Divider
                  Divider(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    thickness: 1,
                    height: 8,
                  ),

                  const SizedBox(height: 12),

                  // Time Left & Seller
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                timeLeft,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Seller Avatar
                      UserAvatar(
                        name: sellerName,
                        imageUrl: sellerImageUrl,
                        size: 36,
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

  /// Widget placeholder khi không có ảnh
  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.tertiary.withValues(alpha: 0.5),
      ),
    );
  }
}
