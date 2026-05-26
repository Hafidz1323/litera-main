import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:litera2/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../models/book_model.dart';
import '../providers/bookmark_provider.dart';
import '../providers/history_provider.dart';
import '../models/reading_history_model.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/rating_bar_widget.dart';
import '../services/book_service.dart';
import 'detail_book_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.myCollection),
          centerTitle: false,
          toolbarHeight: 70,
          backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primary,
                  indicatorColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.myCollection),
                    Tab(text: l10n.readingHistory),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _BookmarkTab(l10n: l10n),
            _HistoryTab(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

// ── Tab Koleksi (Bookmark) ────────────────────────────────────────────────────

class _BookmarkTab extends StatelessWidget {
  final AppLocalizations l10n;
  const _BookmarkTab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            itemBuilder: (_, _) => const BookListSkeleton(),
          );
        }

        if (prov.isEmpty) {
          return EmptyState(
            icon: Icons.bookmark_outline_rounded,
            title: l10n.emptyCollectionTitle,
            message: l10n.emptyCollectionSubtitle,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          physics: const BouncingScrollPhysics(),
          itemCount: prov.bookmarks.length,
          itemBuilder: (_, i) => _BookmarkCard(
            book: prov.bookmarks[i],
            l10n: l10n,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailBookPage(book: prov.bookmarks[i])),
            ),
            onRemove: () => prov.removeBookmark(prov.bookmarks[i].id),
          ),
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookModel book;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.book,
    required this.l10n,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                BookCoverWidget(
                  imageUrl: book.bestCover,
                  width: 70,
                  height: 105,
                  borderRadius: 14,
                  fallbackColor: AppColors.primary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.authorsDisplay,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              book.categoryDisplay,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (book.averageRating > 0) ...[
                            const SizedBox(width: 10),
                            StarDisplay(rating: book.averageRating, starSize: 11),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showRemoveDialog(context),
                  icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.error, size: 22),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.removeBookmark, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Buku "${book.title}" akan dihapus dari koleksi Anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRemove();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ── Tab Riwayat Baca ─────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final AppLocalizations l10n;
  const _HistoryTab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            itemBuilder: (_, _) => const BookListSkeleton(),
          );
        }

        if (prov.isEmpty) {
          return EmptyState(
            icon: Icons.history_edu_rounded,
            title: l10n.emptyHistoryTitle,
            message: l10n.emptyHistorySubtitle,
          );
        }

        final all = prov.history;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          physics: const BouncingScrollPhysics(),
          itemCount: all.length,
          itemBuilder: (_, i) => _HistoryCard(
            history: all[i],
            l10n: l10n,
            onDelete: () => prov.deleteHistory(all[i].bookId),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ReadingHistoryModel history;
  final AppLocalizations l10n;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.history,
    required this.l10n,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => BookService.openBookById(context, history.bookId),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
            BookCoverWidget(
              imageUrl: history.thumbnail,
              width: 70,
              height: 105,
              borderRadius: 14,
              fallbackColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    history.authors,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (history.isFinished)
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Selesai Dibaca',
                          style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  else ...[
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: history.progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.percentDone(history.progressPercent),
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
