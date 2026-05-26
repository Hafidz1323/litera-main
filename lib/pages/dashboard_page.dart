import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:litera2/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../models/book_model.dart';
import '../models/reading_history_model.dart';
import '../providers/book_provider.dart';
import '../providers/history_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_footer.dart';
import '../widgets/book_card.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import '../services/book_service.dart';
import 'detail_book_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadDashboard();
    });
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.greetingMorning;
    if (h < 15) return l10n.greetingAfternoon;
    if (h < 18) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  String _errorText(String key, AppLocalizations l10n) => switch (key) {
        'errorNoInternet' => l10n.errorNoInternet,
        'errorTimeout' => l10n.errorTimeout,
        'errorNoBooksLoaded' => l10n.errorNoBooksLoaded,
        _ => l10n.errorGeneral,
      };

  Map<String, String> _todayQuote(AppLocalizations l10n) {
    final isId = l10n.localeName == 'id';
    final idx = DateTime.now().dayOfYear % AppConstants.quotes.length;
    final q = AppConstants.quotes[idx];
    return {'text': isId ? q['id']! : q['en']!, 'author': q['author']!};
  }

  void _openDetail(BookModel book) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailBookPage(book: book)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = (user?.displayName ?? 'Pembaca').split(' ').first;
    final quote = _todayQuote(l10n);

    return Scaffold(
      backgroundColor: Colors.transparent, // Let CustomScrollView handle BG
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<BookProvider>().loadDashboard(force: true),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ── Premium Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 20, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [AppColors.navBackgroundDark, AppColors.backgroundDark]
                        : [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_greeting(l10n)}, $firstName 👋',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.greetingQuestion,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const SmallProfileAvatar(radius: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Navigation Search Button (Clearly a button now, not a misleading TextField)
                    InkWell(
                      onTap: () => context.read<NavigationProvider>().goToExplore(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.searchHint,
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    "Explore thousands of titles", // Subtext for clarity
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Continue Reading (Horizontal Cards) ──────────────────────
            SliverToBoxAdapter(
              child: Consumer<HistoryProvider>(
                builder: (_, readProv, _) {
                  final list = readProv.continueReading;
                  if (list.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: l10n.continueReading),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140, // Optimized height
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: list.length,
                          itemBuilder: (_, i) => _ContinueReadingCard(
                            history: list[i],
                            isDark: isDark,
                            l10n: l10n,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ),

            // ── Reading Challenge ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Consumer<HistoryProvider>(
                builder: (_, readProv, _) {
                  final finished = readProv.finishedBooks.length;
                  const total = AppConstants.readingChallengeTarget;
                  final progress = (finished / total).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.readingChallenge,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.readingChallengeProgress(finished, total),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Sections (Trending, Popular, etc) ─────────────────────────
            SliverToBoxAdapter(
              child: Consumer<BookProvider>(
                builder: (_, prov, _) => Column(
                  children: [
                    _BookSection(
                      title: l10n.trending,
                      state: prov.dashboardState,
                      books: prov.trendingBooks,
                      onBookTap: _openDetail,
                      onRetry: () => prov.loadDashboard(force: true),
                      errorText: _errorText(prov.dashboardError, l10n),
                    ),
                    _BookSection(
                      title: l10n.popularBooks,
                      state: prov.dashboardState,
                      books: prov.popularBooks,
                      onBookTap: _openDetail,
                      onRetry: () => prov.loadDashboard(force: true),
                      errorText: _errorText(prov.dashboardError, l10n),
                    ),
                    _BookSection(
                      title: l10n.newReleases,
                      state: prov.dashboardState,
                      books: prov.newestBooks,
                      onBookTap: _openDetail,
                      errorText: _errorText(prov.dashboardError, l10n),
                    ),
                  ],
                ),
              ),
            ),

            // ── Recommendation ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Consumer<BookProvider>(
                builder: (_, prov, _) {
                  if (prov.dashboardState == LoadState.loading) return const SizedBox.shrink();
                  if (prov.recommendedBooks.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: l10n.recommendedForYou),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 265, // Fixed height for BookCard (prevent overflow)
                        child: HorizontalBookList(books: prov.recommendedBooks, onBookTap: _openDetail),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ),

            // ── Quote of the Day ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quoteOfTheDay.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            quote['text']!,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '— ${quote['author']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: AppFooter()),
            // Extra padding for floating nav
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w900, 
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookSection extends StatelessWidget {
  final String title;
  final LoadState state;
  final List<BookModel> books;
  final void Function(BookModel) onBookTap;
  final VoidCallback? onRetry;
  final String errorText;

  const _BookSection({
    required this.title,
    required this.state,
    required this.books,
    required this.onBookTap,
    required this.errorText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        const SizedBox(height: 16),
        if (state == LoadState.loading)
          const HorizontalSkeletonRow(count: 4, cardWidth: 120, cardHeight: 170)
        else if (state == LoadState.error)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ErrorState(message: errorText, onRetry: onRetry),
          )
        else if (books.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 265, // Increased height to prevent overflow
            child: HorizontalBookList(books: books, onBookTap: onBookTap),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final ReadingHistoryModel history;
  final bool isDark;
  final AppLocalizations l10n;

  const _ContinueReadingCard({
    required this.history,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => BookService.openBookById(context, history.bookId),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                BookCoverWidget(
                  imageUrl: history.thumbnail,
                  width: 75,
                  height: 110,
                  borderRadius: 16,
                  fallbackColor: AppColors.primary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        history.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        history.authors,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.percentDone(history.progressPercent),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
