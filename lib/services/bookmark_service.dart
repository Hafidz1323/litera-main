import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';

/// Service untuk CRUD bookmark di Firestore
/// Collection: users/{uid}/bookmarks/{bookId}
class BookmarkService {
  static final _firestore = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks');

  // ── Stream realtime ──────────────────────────────────────────────────

  /// Stream semua bookmark user (realtime)
  static Stream<List<BookModel>> watchBookmarks() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _collection(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => BookModel.fromFirestore(doc.data()))
            .toList());
  }

  /// Stream apakah buku tertentu sudah di-bookmark (realtime)
  static Stream<bool> watchIsBookmarked(String bookId) {
    final uid = _uid;
    if (uid == null) return Stream.value(false);

    return _collection(uid)
        .doc(bookId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ── One-time reads ───────────────────────────────────────────────────

  /// Ambil semua bookmark sekali
  static Future<List<BookModel>> getBookmarks() async {
    final uid = _uid;
    if (uid == null) return [];

    final snap = await _collection(uid)
        .orderBy('addedAt', descending: true)
        .get();

    return snap.docs
        .map((doc) => BookModel.fromFirestore(doc.data()))
        .toList();
  }

  /// Cek apakah buku sudah di-bookmark
  static Future<bool> isBookmarked(String bookId) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _collection(uid).doc(bookId).get();
    return doc.exists;
  }

  // ── Write operations ─────────────────────────────────────────────────

  /// Tambah bookmark
  static Future<void> addBookmark(BookModel book) async {
    final uid = _uid;
    if (uid == null) return;

    final data = book.toFirestore();
    data['addedAt'] = FieldValue.serverTimestamp();

    await _collection(uid).doc(book.id).set(data);
  }

  /// Hapus bookmark
  static Future<void> removeBookmark(String bookId) async {
    final uid = _uid;
    if (uid == null) return;
    await _collection(uid).doc(bookId).delete();
  }

  /// Toggle bookmark (tambah jika belum ada, hapus jika sudah)
  static Future<bool> toggleBookmark(BookModel book) async {
    final bookmarked = await isBookmarked(book.id);
    if (bookmarked) {
      await removeBookmark(book.id);
      return false;
    } else {
      await addBookmark(book);
      return true;
    }
  }
}
