import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget cover buku dengan cached image + shimmer placeholder
class BookCoverWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final Color? fallbackColor;
  final IconData? fallbackIcon;

  const BookCoverWidget({
    super.key,
    this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.fallbackColor,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _shimmer(),
                errorWidget: (context, url, error) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.grey[300]),
      );

  Widget _fallback() {
    final color = fallbackColor ?? const Color(0xFF2D5A41);
    return Container(
      color: color,
      child: Center(
        child: Icon(
          fallbackIcon ?? Icons.auto_stories_rounded,
          color: Colors.white.withValues(alpha: 0.4),
          size: width * 0.35,
        ),
      ),
    );
  }
}

/// Shimmer skeleton untuk card buku horizontal
class BookCardSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const BookCardSkeleton({
    super.key,
    this.width = 120,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Skeleton list row (untuk search/library)
class BookListSkeleton extends StatelessWidget {
  const BookListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 95,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, color: Colors.grey[300], width: double.infinity),
                  const SizedBox(height: 8),
                  Container(height: 11, color: Colors.grey[300], width: 100),
                  const SizedBox(height: 16),
                  Container(height: 8, color: Colors.grey[300], width: double.infinity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget horizontal skeleton row
class HorizontalSkeletonRow extends StatelessWidget {
  final int count;
  final double cardWidth;
  final double cardHeight;

  const HorizontalSkeletonRow({
    super.key,
    this.count = 4,
    this.cardWidth = 120,
    this.cardHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count,
        itemBuilder: (_, _) => BookCardSkeleton(
          width: cardWidth,
          height: cardHeight,
        ),
      ),
    );
  }
}
