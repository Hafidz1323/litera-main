import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_constants.dart';
import '../models/book_model.dart';
import 'local_book_service.dart';


/// Service untuk mengambil data dari Google Books API.
/// Fitur: retry on 429, timeout, caching in-memory, pagination.
class GoogleBooksService {
  // ── In-memory cache ──────────────────────────────────────────────────────────
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 10);

  // ── URL Builder ──────────────────────────────────────────────────────────────
  static String _buildUrl(
    String query, {
    int startIndex = 0,
    int maxResults = AppConstants.booksDefaultMax,
    String? orderBy,
    String? langRestrict,
    String? filter,
  }) {
    final buf = StringBuffer(
      '${AppConstants.booksApiBase}?q=${Uri.encodeQueryComponent(query)}',
    );
    buf.write('&maxResults=$maxResults');
    buf.write('&startIndex=$startIndex');
    buf.write('&printType=books');
    if (orderBy != null) buf.write('&orderBy=$orderBy');
    if (langRestrict != null) buf.write('&langRestrict=$langRestrict');
    if (filter != null) buf.write('&filter=$filter');
    if (AppConstants.booksApiKey.isNotEmpty) {
      buf.write('&key=${AppConstants.booksApiKey}');
    }
    return buf.toString();
  }

  // ── HTTP fetch with cache + retry ────────────────────────────────────────────
  static Future<Map<String, dynamic>> _fetchJson(String url) async {
    // Check cache
    final cached = _cache[url];
    if (cached != null && !cached.isExpired) return cached.data;

    Future<http.Response> doGet() =>
        http.get(Uri.parse(url), headers: {'Accept': 'application/json'})
            .timeout(AppConstants.booksTimeout);

    http.Response response;
    try {
      response = await doGet();
    } on TimeoutException {
      throw Exception('errorTimeout');
    } catch (e) {
      throw Exception('errorNoInternet');
    }

    if (response.statusCode == 429) {
      await Future.delayed(AppConstants.booksRetryDelay);
      try {
        response = await doGet();
      } on TimeoutException {
        throw Exception('errorTimeout');
      }
    }

    if (response.statusCode != 200) {
      throw Exception('Google Books API error: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    _cache[url] = _CacheEntry(data);
    return data;
  }

  // ── Parsers ──────────────────────────────────────────────────────────────────
  static List<BookModel> _parseItems(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromJson)
        .where((b) => b.title.isNotEmpty)
        .toList();
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Search books by query, with optional pagination.
  static Future<List<BookModel>> searchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = AppConstants.booksDefaultMax,
  }) async {
    if (query.trim().isEmpty) return [];
    final url = _buildUrl(query, startIndex: startIndex, maxResults: maxResults);
    final result = await _fetchJson(url);
    return _parseItems(result);
  }

  /// Fetch books by category/subject.
  static Future<List<BookModel>> getBooksByCategory(
    String category, {
    int startIndex = 0,
    int maxResults = AppConstants.booksDefaultMax,
  }) async {
    String query = 'subject:$category';
    String? filter;
    String? langRestrict;

    if (category.contains('&')) {
      final parts = category.split('&');
      final baseQuery = parts[0];
      
      // Parse key-value parameters like filter=free-ebooks and langRestrict=id
      for (int i = 1; i < parts.length; i++) {
        final pair = parts[i].split('=');
        if (pair.length == 2) {
          if (pair[0] == 'filter') {
            filter = pair[1];
          } else if (pair[0] == 'langRestrict') {
            langRestrict = pair[1];
          }
        }
      }

      if (baseQuery.startsWith('all:')) {
        query = baseQuery.replaceFirst('all:', '');
      } else {
        query = 'subject:$baseQuery';
      }
    } else if (category.startsWith('all:')) {
      query = category.replaceFirst('all:', '');
    }

    final url = _buildUrl(
      query,
      startIndex: startIndex,
      maxResults: maxResults,
      filter: filter,
      langRestrict: langRestrict,
    );
    final result = await _fetchJson(url);
    return _parseItems(result);
  }

  /// Fetch popular books (fiction, sorted by relevance with cover prioritized).
  static Future<List<BookModel>> getPopularBooks({
    int maxResults = AppConstants.booksDefaultMax,
  }) async {
    final url = _buildUrl('subject:fiction', maxResults: maxResults, orderBy: 'relevance');
    final result = await _fetchJson(url);
    final books = _parseItems(result);
    books.sort((a, b) {
      final aScore = (a.averageRating * 10).toInt() +
          (a.thumbnail != null ? 5 : 0) +
          (a.ratingsCount > 0 ? 3 : 0);
      final bScore = (b.averageRating * 10).toInt() +
          (b.thumbnail != null ? 5 : 0) +
          (b.ratingsCount > 0 ? 3 : 0);
      return bScore.compareTo(aScore);
    });
    return books;
  }

  /// Fetch newest books.
  static Future<List<BookModel>> getNewestBooks({
    int maxResults = AppConstants.booksDefaultMax,
  }) async {
    final url = _buildUrl('subject:fiction', maxResults: maxResults, orderBy: 'newest');
    final result = await _fetchJson(url);
    return _parseItems(result);
  }

  /// Fetch trending books (bestseller query, relevance sort).
  static Future<List<BookModel>> getTrendingBooks({
    int maxResults = AppConstants.booksDefaultMax,
  }) async {
    final url = _buildUrl('bestseller', maxResults: maxResults, orderBy: 'relevance');
    final result = await _fetchJson(url);
    return _parseItems(result);
  }

  /// Fetch books for "Recommended" section based on rotating categories.
  static Future<List<BookModel>> getRecommendations({
    List<String> categories = const ['fiction', 'self-help', 'technology'],
    int maxResults = AppConstants.booksDefaultMax,
  }) async {
    final idx = DateTime.now().millisecondsSinceEpoch % categories.length;
    return getBooksByCategory(categories[idx], maxResults: maxResults);
  }

  /// Fetch detail of a single book by ID.
  static Future<BookModel?> getBookById(String bookId) async {
    if (bookId.startsWith('local_')) {
      try {
        return LocalBookService.localBooks.firstWhere((b) => b.id == bookId);
      } catch (_) {
        return null;
      }
    }
    final url = AppConstants.booksApiKey.isNotEmpty
        ? '${AppConstants.booksApiBase}/$bookId?key=${AppConstants.booksApiKey}'
        : '${AppConstants.booksApiBase}/$bookId';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as Map<String, dynamic>;
      return BookModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Fetch related books based on category or author of a given book.
  static Future<List<BookModel>> getRelatedBooks(
    BookModel book, {
    int maxResults = 8,
  }) async {
    String query;
    if (book.categories.isNotEmpty) {
      query = 'subject:${book.categories.first}';
    } else if (book.authors.isNotEmpty) {
      query = 'inauthor:${book.authors.first}';
    } else {
      query = book.title.split(' ').take(2).join(' ');
    }
    final url = _buildUrl(query, maxResults: maxResults);
    try {
      final data = await _fetchJson(url);
      final books = _parseItems(data);
      return books.where((b) => b.id != book.id).take(6).toList();
    } catch (_) {
      return [];
    }
  }

  /// Invalidate entire cache (call on pull-to-refresh).
  static void clearCache() => _cache.clear();
}

// ── Cache Entry ──────────────────────────────────────────────────────────────
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime _createdAt = DateTime.now();

  _CacheEntry(this.data);

  bool get isExpired =>
      DateTime.now().difference(_createdAt) > GoogleBooksService._cacheTtl;
}

// ── Book Categories ──────────────────────────────────────────────────────────
class BookCategory {
  final String label;
  final String query;

  const BookCategory({required this.label, required this.query});

  static const List<BookCategory> all = [
    BookCategory(label: 'Semua', query: 'bestseller'),
    BookCategory(label: 'Gratis Indonesia', query: 'all:*&filter=free-ebooks&langRestrict=id'),
    BookCategory(label: 'Gratis Global', query: 'all:classic&filter=free-ebooks'),
    BookCategory(label: 'Sastra Indo', query: 'all:sastra indonesia&langRestrict=id'),
    BookCategory(label: 'Sejarah Indo', query: 'all:sejarah indonesia&langRestrict=id'),
    BookCategory(label: 'Novel', query: 'subject:fiction novel'),
    BookCategory(label: 'Teknologi', query: 'subject:technology computers'),
    BookCategory(label: 'Bisnis', query: 'subject:business economics'),
    BookCategory(label: 'Sejarah', query: 'subject:history'),
    BookCategory(label: 'Self-Help', query: 'subject:self-help motivation'),
    BookCategory(label: 'Romance', query: 'subject:romance love'),
    BookCategory(label: 'Fantasy', query: 'subject:fantasy magic'),
    BookCategory(label: 'Sains', query: 'subject:science popular'),
    BookCategory(label: 'Biografi', query: 'subject:biography autobiography'),
    BookCategory(label: 'Horror', query: 'subject:horror thriller'),
    BookCategory(label: 'Edukasi', query: 'subject:education'),
  ];
}
