import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/theme/app_colors.dart';

/// Optimized image widget with caching and shimmer loading
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int? memCacheHeight;
  final int? memCacheWidth;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheHeight = 400,
    this.memCacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        memCacheHeight: memCacheHeight,
        memCacheWidth: memCacheWidth,
        maxHeightDiskCache: (memCacheHeight ?? 400) * 2,
        maxWidthDiskCache: memCacheWidth != null ? memCacheWidth! * 2 : null,
        placeholder: (context, url) => _buildShimmer(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey.withOpacity(0.3),
      highlightColor: AppColors.grey.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        color: AppColors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.2),
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.grey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.2),
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
