import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class AdminService {
  static final _firestore = FirebaseFirestore.instance;
  static final CollectionReference _booksCol = _firestore.collection('books');

  /// Stream all books for the dashboard
  static Stream<List<BookModel>> watchAllBooks() {
    return _booksCol.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Get total books count once
  static Future<int> getBooksCount() async {
    final snapshot = await _booksCol.count().get();
    return snapshot.count ?? 0;
  }

  /// Get recent books (last 5)
  static Future<List<BookModel>> getRecentBooks({int limit = 5}) async {
    final snapshot = await _booksCol.orderBy('createdAt', descending: true).limit(limit).get();
    return snapshot.docs
        .map((doc) => BookModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Add a new book
  static Future<void> addBook(BookModel book) async {
    final docRef = _booksCol.doc();
    // Create a new model with the generated ID
    final bookWithId = BookModel(
      id: docRef.id,
      title: book.title,
      authors: book.authors,
      categories: book.categories,
      thumbnail: book.thumbnail,
      epubDownloadLink: book.epubDownloadLink,
      description: book.description,
      subtitle: book.subtitle,
      publisher: book.publisher,
      publishedDate: book.publishedDate,
      pageCount: book.pageCount,
      language: book.language,
      previewLink: book.previewLink,
      infoLink: book.infoLink,
      isEbook: book.isEbook,
    );
    
    await docRef.set(bookWithId.toFirestore());
  }

  /// Update an existing book
  static Future<void> updateBook(BookModel book) async {
    if (book.id.isEmpty) throw Exception("Book ID cannot be empty for updates");
    await _booksCol.doc(book.id).set(book.toFirestore(), SetOptions(merge: true));
  }

  /// Delete a book
  static Future<void> deleteBook(String bookId) async {
    await _booksCol.doc(bookId).delete();
  }
}
