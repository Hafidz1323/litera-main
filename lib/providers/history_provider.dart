import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/reading_history_model.dart';
import '../services/reading_history_service.dart';

/// Provider untuk state riwayat membaca, dengan realtime sync ke Firestore
class HistoryProvider extends ChangeNotifier {
  List<ReadingHistoryModel> _history = [];
  bool _isLoading = false;
  String _error = '';

  StreamSubscription<List<ReadingHistoryModel>>? _subscription;

  // ── Getters ──────────────────────────────────────────────────────────
  List<ReadingHistoryModel> get history => _history;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isEmpty => _history.isEmpty;

  /// Buku yang terakhir dibaca (untuk "Lanjutkan Membaca")
  List<ReadingHistoryModel> get continueReading =>
      _history.where((h) => !h.isFinished).take(5).toList();

  /// Buku yang sudah selesai
  List<ReadingHistoryModel> get finishedBooks =>
      _history.where((h) => h.isFinished).toList();

  /// Progress buku tertentu (0.0 jika belum pernah dibuka)
  double progressOf(String bookId) {
    try {
      return _history.firstWhere((h) => h.bookId == bookId).progress;
    } catch (_) {
      return 0.0;
    }
  }

  bool hasHistory(String bookId) => _history.any((h) => h.bookId == bookId);

  // ── Init / Dispose ───────────────────────────────────────────────────

  void startListening() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = ReadingHistoryService.watchRecentlyRead(limit: 20).listen(
      (history) {
        _history = history;
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = 'Gagal memuat riwayat baca.';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _history = [];
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

  Future<void> updateProgress(
    String bookId, {
    required double progress,
    required int lastPage,
  }) async {
    // Optimistic update
    final idx = _history.indexWhere((h) => h.bookId == bookId);
    if (idx != -1) {
      _history[idx] = _history[idx].copyWith(
        progress: progress,
        lastPage: lastPage,
        lastReadAt: DateTime.now(),
      );
      notifyListeners();
    }

    await ReadingHistoryService.updateProgress(
      bookId,
      progress: progress,
      lastPage: lastPage,
    );
  }

  Future<void> deleteHistory(String bookId) async {
    _history.removeWhere((h) => h.bookId == bookId);
    notifyListeners();
    await ReadingHistoryService.deleteHistory(bookId);
  }

  Future<void> clearAll() async {
    _history = [];
    notifyListeners();
    await ReadingHistoryService.clearAllHistory();
  }
}
