import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/bookmark_service.dart';

/// Provider untuk state bookmark, dengan realtime sync ke Firestore
class BookmarkProvider extends ChangeNotifier {
  List<BookModel> _bookmarks = [];
  bool _isLoading = false;
  String _error = '';

  // Cache set untuk cek cepat O(1)
  final Set<String> _bookmarkedIds = {};

  StreamSubscription<List<BookModel>>? _subscription;

  // ── Getters ──────────────────────────────────────────────────────────
  List<BookModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isEmpty => _bookmarks.isEmpty;

  bool isBookmarked(String bookId) => _bookmarkedIds.contains(bookId);

  // ── Init / Dispose ───────────────────────────────────────────────────

  /// Mulai listen ke Firestore realtime stream
  void startListening() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = BookmarkService.watchBookmarks().listen(
      (books) {
        _bookmarks = books;
        _bookmarkedIds
          ..clear()
          ..addAll(books.map((b) => b.id));
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = 'Gagal memuat koleksi. Coba lagi.';
        notifyListeners();
      },
    );
  }

  /// Hentikan listener saat user logout
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _bookmarks = [];
    _bookmarkedIds.clear();
    _isLoading = false;
    _error = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────

  /// Toggle bookmark — return true jika ditambahkan, false jika dihapus
  Future<bool> toggleBookmark(BookModel book) async {
    final wasBookmarked = isBookmarked(book.id);

    // Optimistic update
    if (wasBookmarked) {
      _bookmarkedIds.remove(book.id);
      _bookmarks.removeWhere((b) => b.id == book.id);
    } else {
      _bookmarkedIds.add(book.id);
      _bookmarks.insert(0, book);
    }
    notifyListeners();

    try {
      await BookmarkService.toggleBookmark(book);
      return !wasBookmarked;
    } catch (e) {
      // Rollback jika gagal
      if (wasBookmarked) {
        _bookmarkedIds.add(book.id);
        _bookmarks.insert(0, book);
      } else {
        _bookmarkedIds.remove(book.id);
        _bookmarks.removeWhere((b) => b.id == book.id);
      }
      notifyListeners();
      return wasBookmarked;
    }
  }

  Future<void> addBookmark(BookModel book) async {
    if (isBookmarked(book.id)) return;
    await toggleBookmark(book);
  }

  Future<void> removeBookmark(String bookId) async {
    if (!isBookmarked(bookId)) return;

    // Optimistic update
    final removedBook = _bookmarks.firstWhere((b) => b.id == bookId);
    _bookmarkedIds.remove(bookId);
    _bookmarks.removeWhere((b) => b.id == bookId);
    notifyListeners();

    try {
      await BookmarkService.removeBookmark(bookId);
    } catch (e) {
      // Rollback
      _bookmarkedIds.add(bookId);
      _bookmarks.insert(0, removedBook);
      notifyListeners();
    }
  }
}
