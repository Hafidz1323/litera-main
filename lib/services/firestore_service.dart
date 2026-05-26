import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  /// Update book aggregate data (averageRating, totalRatings, totalReviews)
  /// Also ensures basic book info exists if document is missing.
  static Future<void> updateBookStats(String bookId) async {
    final ratingsCol = _firestore.collection('books').doc(bookId).collection('ratings');
    final ratingsSnap = await ratingsCol.get();

    if (ratingsSnap.docs.isEmpty) {
      await _firestore.collection('books').doc(bookId).set({
        'averageRating': 0.0,
        'totalRatings': 0,
        'totalReviews': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    double totalRatingSum = 0;
    int reviewWithTextCount = 0;
    
    for (var doc in ratingsSnap.docs) {
      final data = doc.data();
      totalRatingSum += (data['rating'] as num?)?.toDouble() ?? 0.0;
      
      final reviewText = data['review'] as String?;
      if (reviewText != null && reviewText.trim().isNotEmpty) {
        reviewWithTextCount++;
      }
    }

    final totalRatings = ratingsSnap.docs.length;
    final averageRating = totalRatingSum / totalRatings;

    await _firestore.collection('books').doc(bookId).set({
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'totalReviews': reviewWithTextCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// One-time initialization of book data if it doesn't exist.
  /// Called when a book is first viewed or rated.
  static Future<void> ensureBookExists({
    required String bookId,
    required String title,
    required String thumbnail,
    required String category,
  }) async {
    final docRef = _firestore.collection('books').doc(bookId);
    final docSnap = await docRef.get();
    
    if (!docSnap.exists) {
      await docRef.set({
        'title': title,
        'thumbnail': thumbnail,
        'category': category,
        'averageRating': 0.0,
        'totalRatings': 0,
        'totalReviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
