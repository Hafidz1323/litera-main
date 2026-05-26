import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:litera2/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../providers/book_provider.dart';
import '../models/book_model.dart';
import '../services/google_books_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/book_card.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/rating_bar_widget.dart';
import 'detail_book_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isSearchMode = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cat = BookCategory.all[_selectedIndex];
      context.read<BookProvider>().loadCategory(cat.label, cat.query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      final prov = context.read<BookProvider>();
      if (_isSearchMode) {
        prov.loadMoreSearch();
      } else {
        final cat = BookCategory.all[_selectedIndex];
        prov.loadMoreCategory(cat.query);
      }
    }
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    if (val.trim().isEmpty) {
      setState(() => _isSearchMode = false);
      context.read<BookProvider>().clearSearch();
      return;
    }
    setState(() => _isSearchMode = true);
    _debounce = Timer(const Duration(milliseconds: 600), () {
      context.read<BookProvider>().searchBooks(val);
    });
  }

  void _onCategoryTap(int index) {
    if (_selectedIndex == index && !_isSearchMode) return;
    setState(() {
      _selectedIndex = index;
      _isSearchMode = false;
    });
    _searchController.clear();
    context.read<BookProvider>().clearSearch();
    final cat = BookCategory.all[index];
    context.read<BookProvider>().loadCategory(cat.label, cat.query);
  }

  void _openDetail(BookModel book) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailBookPage(book: book)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Premium Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 16, 20, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: l10n.searchBooksHint,
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                suffixIcon: _isSearchMode
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, prov, _) {
                if (_isSearchMode) {
                  if (prov.searchState == LoadState.loading && prov.searchResults.isEmpty) {
                    return ListView.builder(padding: const EdgeInsets.all(20), itemCount: 5, itemBuilder: (_, _) => const BookListSkeleton());
                  }
                  if (prov.searchState == LoadState.error && prov.searchResults.isEmpty) {
                    return ErrorState(message: _errorText(prov.searchError, l10n), onRetry: () => prov.searchBooks(_searchController.text));
                  }
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              if (i >= prov.searchResults.length) {
                                return const BookListSkeleton();
                              }
                              return _SearchItem(book: prov.searchResults[i], onTap: _openDetail, isDark: isDark);
                            },
                            childCount: prov.searchResults.length + (prov.isSearchLoading ? 1 : 0),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: AppFooter()),
                    ],
                  );
                }

                // Category View
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Category chips as a sliver to follow scroll
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: BookCategory.all.length,
                          itemBuilder: (context, i) {
                            final isSelected = i == _selectedIndex;
                            final cat = BookCategory.all[i];
                            final label = cat.label == 'Semua' ? l10n.categoryAll : cat.label;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FilterChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (_) => _onCategoryTap(i),
                                backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.primaryDark),
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? Colors.transparent : AppColors.primary.withValues(alpha: 0.1),
                                  ),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    if (prov.categoryState == LoadState.loading && prov.categoryBooks.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, 
                            crossAxisSpacing: 16, 
                            mainAxisSpacing: 16, 
                            childAspectRatio: 0.48
                          ),
                          delegate: SliverChildBuilderDelegate((_, _) => const BookCardSkeleton(width: double.infinity, height: double.infinity), childCount: 6),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24, // More spacing for better breathability
                            childAspectRatio: 0.46, // Adjusted for the larger BookCard to prevent overflow
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              if (i >= prov.categoryBooks.length) {
                                return const BookCardSkeleton(width: double.infinity, height: double.infinity);
                              }
                              return BookCard(
                                book: prov.categoryBooks[i],
                                width: double.infinity,
                                coverHeight: 180, // Slightly taller cover for Explore grid
                                onTap: () => _openDetail(prov.categoryBooks[i]),
                              );
                            },
                            childCount: prov.categoryBooks.length + (prov.categoryHasMore ? 2 : 0),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: AppFooter()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _errorText(String key, AppLocalizations l10n) => switch (key) {
        'errorNoInternet' => l10n.errorNoInternet,
        'errorTimeout' => l10n.errorTimeout,
        _ => l10n.errorGeneral,
      };
}

class _SearchItem extends StatelessWidget {
  final BookModel book;
  final void Function(BookModel) onTap;
  final bool isDark;

  const _SearchItem({
    required this.book,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(book),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'search-${book.id}',
                  child: BookCoverWidget(
                    imageUrl: book.bestCover,
                    width: 70,
                    height: 100,
                    borderRadius: 12,
                    fallbackColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, height: 1.2),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (book.averageRating > 0) ...[
                            StarDisplay(rating: book.averageRating, starSize: 11),
                            const SizedBox(width: 10),
                          ],
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
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
