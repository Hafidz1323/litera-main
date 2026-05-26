import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/google_books_service.dart';
import '../services/local_book_service.dart';

/// Load state enum shared across all provider sections.
enum LoadState { idle, loading, loaded, error }

/// Provider for all Google Books API data used across the app.
class BookProvider extends ChangeNotifier {
  // ── Dashboard ────────────────────────────────────────────────────────────────
  List<BookModel> _popularBooks = [];
  List<BookModel> _newestBooks = [];
  List<BookModel> _recommendedBooks = [];
  List<BookModel> _trendingBooks = [];

  LoadState _dashboardState = LoadState.idle;
  String _dashboardError = '';

  // ── Category / Explore ───────────────────────────────────────────────────────
  List<BookModel> _categoryBooks = [];
  LoadState _categoryState = LoadState.idle;
  String _categoryError = '';
  String _selectedCategory = 'Semua';
  bool _categoryHasMore = true;
  int _categoryPage = 0;

  // ── Search ───────────────────────────────────────────────────────────────────
  List<BookModel> _searchResults = [];
  LoadState _searchState = LoadState.idle;
  String _searchError = '';
  String _lastQuery = '';
  bool _searchHasMore = true;
  int _searchPage = 0;

  // ── Related books (detail page) ───────────────────────────────────────────────
  List<BookModel> _relatedBooks = [];
  LoadState _relatedState = LoadState.idle;

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<BookModel> get popularBooks => _popularBooks;
  List<BookModel> get newestBooks => _newestBooks;
  List<BookModel> get recommendedBooks => _recommendedBooks;
  List<BookModel> get trendingBooks => _trendingBooks;
  LoadState get dashboardState => _dashboardState;
  String get dashboardError => _dashboardError;
  bool get isDashboardLoading => _dashboardState == LoadState.loading;

  List<BookModel> get categoryBooks => _categoryBooks;
  LoadState get categoryState => _categoryState;
  String get categoryError => _categoryError;
  String get selectedCategory => _selectedCategory;
  bool get isCategoryLoading => _categoryState == LoadState.loading;
  bool get categoryHasMore => _categoryHasMore;

  List<BookModel> get searchResults => _searchResults;
  LoadState get searchState => _searchState;
  String get searchError => _searchError;
  bool get isSearchLoading => _searchState == LoadState.loading;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get searchHasMore => _searchHasMore;

  List<BookModel> get relatedBooks => _relatedBooks;
  LoadState get relatedState => _relatedState;

  // ── Dashboard ─────────────────────────────────────────────────────────────────

  Future<void> loadDashboard({bool force = false}) async {
    if (_dashboardState == LoadState.loading) return;
    if (_dashboardState == LoadState.loaded && !force) return;
    if (force) GoogleBooksService.clearCache();

    _dashboardState = LoadState.loading;
    _dashboardError = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _safeLoad(() => GoogleBooksService.getPopularBooks(maxResults: 10)),
        _safeLoad(() => GoogleBooksService.getNewestBooks(maxResults: 10)),
        _safeLoad(() => GoogleBooksService.getRecommendations(
              categories: ['fiction', 'self-help', 'technology'],
              maxResults: 10,
            )),
        _safeLoad(() => GoogleBooksService.getTrendingBooks(maxResults: 10)),
      ]);

      _popularBooks = results[0];
      _newestBooks = results[1];
      _recommendedBooks = results[2];
      _trendingBooks = results[3];

      // Inject local books at the beginning of each list
      final local = LocalBookService.localBooks;
      final cantikLuka = local.firstWhere((b) => b.id == 'local_cantik_itu_luka');
      final ronggeng = local.firstWhere((b) => b.id == 'local_ronggeng_dukuh_paruk');
      final sejarahDunia = local.firstWhere((b) => b.id == 'local_sejarah_disembunyikan');
      final thermo = local.firstWhere((b) => b.id == 'local_thermodynamics');
      final konflik = local.firstWhere((b) => b.id == 'local_konflik_kolaborasi');
      final broken = local.firstWhere((b) => b.id == 'local_broken_strings');

      _popularBooks = [sejarahDunia, broken, ..._popularBooks];
      _newestBooks = [broken, konflik, ..._newestBooks];
      _recommendedBooks = [thermo, ..._recommendedBooks];
      _trendingBooks = [cantikLuka, ronggeng, ..._trendingBooks];

      final anyLoaded = _popularBooks.isNotEmpty ||
          _newestBooks.isNotEmpty ||
          _recommendedBooks.isNotEmpty ||
          _trendingBooks.isNotEmpty;

      if (!anyLoaded) {
        _dashboardState = LoadState.error;
        _dashboardError = 'errorNoBooksLoaded';
      } else {
        _dashboardState = LoadState.loaded;
      }
    } catch (e) {
      _dashboardState = LoadState.error;
      _dashboardError = _friendlyError(e);
    }

    notifyListeners();
  }

  // ── Category ──────────────────────────────────────────────────────────────────

  Future<void> loadCategory(String category, String apiQuery) async {
    if (_selectedCategory == category && _categoryState == LoadState.loaded) return;

    _selectedCategory = category;
    _categoryState = LoadState.loading;
    _categoryError = '';
    _categoryBooks = [];
    _categoryPage = 0;
    _categoryHasMore = true;
    notifyListeners();

    try {
      final localMatches = LocalBookService.getBooksByCategory(category);
      final books = await _fetchCategoryPage(category, apiQuery, 0);
      _categoryBooks = [...localMatches, ...books];
      _categoryHasMore = books.length >= 20;
      _categoryState = _categoryBooks.isEmpty ? LoadState.error : LoadState.loaded;
      if (_categoryBooks.isEmpty) _categoryError = 'errorNoBooks';
    } catch (e) {
      _categoryState = LoadState.error;
      _categoryError = _friendlyError(e);
    }

    notifyListeners();
  }

  /// Load next page for infinite scroll.
  Future<void> loadMoreCategory(String apiQuery) async {
    if (_categoryState == LoadState.loading || !_categoryHasMore) return;
    _categoryPage++;
    try {
      final more = await _fetchCategoryPage(_selectedCategory, apiQuery, _categoryPage);
      _categoryBooks.addAll(more);
      _categoryHasMore = more.length >= 20;
    } catch (_) {
      _categoryHasMore = false;
    }
    notifyListeners();
  }

  Future<List<BookModel>> _fetchCategoryPage(
    String category,
    String apiQuery,
    int page,
  ) async {
    if (category == 'Semua') {
      return GoogleBooksService.getPopularBooks(maxResults: 20);
    }
    return GoogleBooksService.searchBooks(
      apiQuery,
      startIndex: page * 20,
      maxResults: 20,
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────────

  Future<void> searchBooks(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      _searchResults = [];
      _searchState = LoadState.idle;
      _lastQuery = '';
      notifyListeners();
      return;
    }

    if (q == _lastQuery && _searchState == LoadState.loaded) return;

    _lastQuery = q;
    _searchState = LoadState.loading;
    _searchError = '';
    _searchPage = 0;
    _searchHasMore = true;
    notifyListeners();

    try {
      final localMatches = LocalBookService.searchBooks(q);
      final apiResults = await GoogleBooksService.searchBooks(q, maxResults: 20);
      _searchResults = [...localMatches, ...apiResults];
      _searchHasMore = apiResults.length >= 20;
      _searchState = LoadState.loaded;
    } catch (e) {
      _searchState = LoadState.error;
      _searchError = _friendlyError(e);
    }

    notifyListeners();
  }

  Future<void> loadMoreSearch() async {
    if (_searchState == LoadState.loading || !_searchHasMore || _lastQuery.isEmpty) return;
    _searchPage++;
    try {
      final more = await GoogleBooksService.searchBooks(
        _lastQuery,
        startIndex: _searchPage * 20,
        maxResults: 20,
      );
      _searchResults.addAll(more);
      _searchHasMore = more.length >= 20;
    } catch (_) {
      _searchHasMore = false;
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _searchState = LoadState.idle;
    _lastQuery = '';
    _searchError = '';
    _searchHasMore = true;
    _searchPage = 0;
    notifyListeners();
  }

  // ── Related ───────────────────────────────────────────────────────────────────

  Future<void> loadRelatedBooks(BookModel book) async {
    _relatedBooks = [];
    _relatedState = LoadState.loading;
    notifyListeners();
    try {
      _relatedBooks = await GoogleBooksService.getRelatedBooks(book);
      _relatedState = LoadState.loaded;
    } catch (_) {
      _relatedState = LoadState.error;
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Future<List<BookModel>> _safeLoad(Future<List<BookModel>> Function() loader) async {
    try {
      return await loader();
    } catch (e) {
      debugPrint('[BookProvider] _safeLoad error: $e');
      return [];
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host lookup') || msg.contains('errorNoInternet')) {
      return 'errorNoInternet';
    }
    if (msg.contains('TimeoutException') || msg.contains('errorTimeout')) {
      return 'errorTimeout';
    }
    return 'errorGeneral';
  }
}
