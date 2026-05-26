import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/book_model.dart';
import 'book_cover_widget.dart';
import 'rating_bar_widget.dart';

/// Premium Vertical Book Card (Optimized to prevent overflows)
class BookCard extends StatelessWidget {
  final BookModel book;
  final double width;
  final double coverHeight;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.width = 120,
    this.coverHeight = 170, // Increased for better aspect ratio
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover with Premium Shadow & Border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BookCoverWidget(
                  imageUrl: book.bestCover,
                  width: width,
                  height: coverHeight,
                  borderRadius: 16,
                  fallbackColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title - Fixed height to avoid shifting layout
            SizedBox(
              height: 36, // Exactly 2 lines worth of height
              child: Text(
                book.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Author
            Text(
              book.authorsDisplay,
              style: const TextStyle(
                fontSize: 11, 
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Rating
            if (book.averageRating > 0)
              StarDisplay(rating: book.averageRating, starSize: 11)
            else
              const SizedBox(height: 11), // Placeholder to keep height consistent
          ],
        ),
      ),
    );
  }
}

/// Responsive Horizontal Book List
class HorizontalBookList extends StatelessWidget {
  final List<BookModel> books;
  final double cardWidth;
  final double coverHeight;
  final void Function(BookModel)? onBookTap;

  const HorizontalBookList({
    super.key,
    required this.books,
    this.cardWidth = 120,
    this.coverHeight = 170,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24), // Consistent spacing
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, i) => BookCard(
        book: books[i],
        width: cardWidth,
        coverHeight: coverHeight,
        onTap: () => onBookTap?.call(books[i]),
      ),
    );
  }
}
