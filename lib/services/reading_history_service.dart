import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/reading_history_model.dart';

/// Service untuk CRUD riwayat membaca di Firestore
/// Collection: users/{uid}/reading_history/{bookId}
class ReadingHistoryService {
  static final _firestore = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('history');

  // ── Streams ──────────────────────────────────────────────────────────

  /// Stream riwayat membaca terbaru (realtime)
  static Stream<List<ReadingHistoryModel>> watchRecentlyRead({int limit = 10}) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _collection(uid)
        .orderBy('lastReadAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReadingHistoryModel.fromFirestore(doc.data()))
            .toList());
  }

  /// Stream satu entri history buku tertentu
  static Stream<ReadingHistoryModel?> watchBookHistory(String bookId) {
    final uid = _uid;
    if (uid == null) return Stream.value(null);

    return _collection(uid)
        .doc(bookId)
        .snapshots()
        .map((doc) => doc.exists
            ? ReadingHistoryModel.fromFirestore(doc.data()!)
            : null);
  }

  // ── One-time reads ───────────────────────────────────────────────────

  /// Ambil riwayat terbaru sekali
  static Future<List<ReadingHistoryModel>> getRecentlyRead({int limit = 10}) async {
    final uid = _uid;
    if (uid == null) return [];

    final snap = await _collection(uid)
        .orderBy('lastReadAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((doc) => ReadingHistoryModel.fromFirestore(doc.data()))
        .toList();
  }

  /// Ambil history buku tertentu
  static Future<ReadingHistoryModel?> getBookHistory(String bookId) async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = await _collection(uid).doc(bookId).get();
    if (!doc.exists) return null;
    return ReadingHistoryModel.fromFirestore(doc.data()!);
  }

  // ── Write operations ─────────────────────────────────────────────────

  /// Catat/update riwayat membaca saat buku dibuka
  static Future<void> recordBookOpen(BookModel book) async {
    final uid = _uid;
    if (uid == null) return;

    final now = DateTime.now();
    final existing = await getBookHistory(book.id);

    if (existing != null) {
      // Update lastReadAt saja
      await _collection(uid).doc(book.id).update({
        'lastReadAt': Timestamp.fromDate(now),
      });
    } else {
      // Buat entri baru
      final entry = ReadingHistoryModel(
        bookId: book.id,
        title: book.title,
        authors: book.authorsDisplay,
        thumbnail: book.bestCover,
        progress: 0.0,
        lastPage: 0,
        totalPages: book.pageCount,
        lastReadAt: now,
        addedAt: now,
      );
      await _collection(uid).doc(book.id).set(entry.toFirestore());
    }
  }

  /// Update progress membaca
  static Future<void> updateProgress(
    String bookId, {
    required double progress,
    required int lastPage,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _collection(uid).doc(bookId).update({
      'progress': progress.clamp(0.0, 1.0),
      'lastPage': lastPage,
      'lastReadAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Tandai buku selesai dibaca
  static Future<void> markAsFinished(String bookId) async {
    final uid = _uid;
    if (uid == null) return;

    await _collection(uid).doc(bookId).update({
      'progress': 1.0,
      'lastReadAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Hapus satu entri history
  static Future<void> deleteHistory(String bookId) async {
    final uid = _uid;
    if (uid == null) return;
    await _collection(uid).doc(bookId).delete();
  }

  /// Hapus semua riwayat
  static Future<void> clearAllHistory() async {
    final uid = _uid;
    if (uid == null) return;

    final snap = await _collection(uid).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
