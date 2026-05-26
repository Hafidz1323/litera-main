import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/app_constants.dart';
import '../models/review_model.dart';


/// Handles all Firestore operations for book ratings and reviews.
/// Collection path: books/{bookId}/ratings/{userId}
class RatingService {
  static final _firestore = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _ratingsCol(String bookId) =>
      _firestore
          .collection('books')
          .doc(bookId)
          .collection(AppConstants.colRatings);

  // ── Streams ─────────────────────────────────────────────────────────────────

  /// Realtime stream of all reviews for a book, ordered by createdAt desc.
  static Stream<List<ReviewModel>> watchReviews(String bookId) {
    // includeMetadataChanges: true allows us to see local changes immediately
    return _ratingsCol(bookId)
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs
            .map((d) => ReviewModel.fromFirestore(
                  d.data(), 
                  d.id,
                ))
            .toList());
  }

  /// Realtime stream of the current user's review for a book.
  static Stream<ReviewModel?> watchMyReview(String bookId) {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _ratingsCol(bookId).doc(uid).snapshots().map((doc) =>
        doc.exists ? ReviewModel.fromFirestore(doc.data()!, doc.id) : null);
  }

  // ── Reads ───────────────────────────────────────────────────────────────────

  /// Fetch all reviews for a book once.
  static Future<List<ReviewModel>> getReviews(
    String bookId, {
    bool sortByRating = false,
  }) async {
    try {
      final query = sortByRating
          ? _ratingsCol(bookId).orderBy('rating', descending: true)
          : _ratingsCol(bookId).orderBy('createdAt', descending: true);
      final snap = await query.get();
      return snap.docs
          .map((d) => ReviewModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e) {
      debugPrint('[RatingService] getStats error: $e');
      return [];
    }
  }

  /// Fetch current user's review once.
  static Future<ReviewModel?> getMyReview(String bookId) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final doc = await _ratingsCol(bookId).doc(uid).get();
      if (!doc.exists) return null;
      return ReviewModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('[RatingService] getMyReview error: $e');
      return null;
    }
  }

  /// Get aggregate stats (average, count) for a book from book document directly
  static Future<({double average, int count, int reviews})> getStats(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (!doc.exists) return (average: 0.0, count: 0, reviews: 0);
      final data = doc.data()!;
      return (
        average: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
        count: (data['totalRatings'] as int?) ?? 0,
        reviews: (data['totalReviews'] as int?) ?? 0
      );
    } catch (e) {
      debugPrint('[RatingService] getStats error: $e');
      return (average: 0.0, count: 0, reviews: 0);
    }
  }

  // ── Writes ──────────────────────────────────────────────────────────────────

  /// Submit or update the current user's rating.
  /// Enforces authentication and uses a Transaction for atomic updates.
  static Future<void> submitRating({
    required String bookId,
    required double rating,
    required String review,
  }) async {
    debugPrint('[RatingService] 🚀 Starting atomic submitRating for bookId: $bookId');
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[RatingService] ❌ Error: No user logged in');
      throw Exception('User must be logged in to rate.');
    }

    final uid = user.uid;
    final ratingDocRef = _ratingsCol(bookId).doc(uid);
    final bookDocRef = _firestore.collection('books').doc(bookId);

    try {
      await _firestore.runTransaction((transaction) async {
        debugPrint('[RatingService] 🔄 Transaction started for UID: $uid');
        
        final ratingDocSnap = await transaction.get(ratingDocRef);
        final bookDocSnap = await transaction.get(bookDocRef);
        
        final bool isNewReview = !ratingDocSnap.exists;
        final double oldRating = isNewReview ? 0.0 : (ratingDocSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;
        final String oldReview = isNewReview ? '' : (ratingDocSnap.data()?['review'] as String? ?? '');
        
        final bool isAddingReviewText = review.trim().isNotEmpty && oldReview.trim().isEmpty;
        final bool isRemovingReviewText = review.trim().isEmpty && oldReview.trim().isNotEmpty;

        final ratingData = {
          'userId': uid,
          'userName': user.displayName ?? 'Pengguna',
          'userPhoto': user.photoURL,
          'bookId': bookId,
          'rating': rating,
          'review': review,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (isNewReview) {
          ratingData['createdAt'] = FieldValue.serverTimestamp();
          transaction.set(ratingDocRef, ratingData);
        } else {
          transaction.update(ratingDocRef, ratingData);
        }

        // --- Update Book Aggregates ---
        final Map<String, dynamic> bookUpdate = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (!bookDocSnap.exists) {
          // Initialize book doc if missing
          bookUpdate['totalRatings'] = 1;
          bookUpdate['totalRatingSum'] = rating;
          bookUpdate['averageRating'] = rating;
          bookUpdate['totalReviews'] = review.trim().isNotEmpty ? 1 : 0;
          transaction.set(bookDocRef, bookUpdate, SetOptions(merge: true));
        } else {
          final bookData = bookDocSnap.data()!;
          int totalRatings = (bookData['totalRatings'] as int? ?? 0);
          double totalRatingSum = (bookData['totalRatingSum'] as num? ?? 0.0).toDouble();
          int totalReviews = (bookData['totalReviews'] as int? ?? 0);

          if (isNewReview) {
            totalRatings += 1;
            totalRatingSum += rating;
            if (review.trim().isNotEmpty) totalReviews += 1;
          } else {
            totalRatingSum = totalRatingSum - oldRating + rating;
            if (isAddingReviewText) totalReviews += 1;
            if (isRemovingReviewText) totalReviews -= 1;
          }

          bookUpdate['totalRatings'] = totalRatings;
          bookUpdate['totalRatingSum'] = totalRatingSum;
          bookUpdate['averageRating'] = totalRatings > 0 ? totalRatingSum / totalRatings : 0.0;
          bookUpdate['totalReviews'] = totalReviews;
          transaction.update(bookDocRef, bookUpdate);
        }
      });

      debugPrint('[RatingService] ✅ Transaction committed successfully');
    } catch (e, stack) {
      debugPrint('[RatingService] ❌ TRANSACTION FAILED: $e');
      debugPrint('[RatingService] 📜 StackTrace: $stack');
      rethrow;
    }
  }

  /// Delete current user's rating for a book.
  static Future<void> deleteRating(String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User must be logged in.');
    
    final uid = user.uid;
    final ratingDocRef = _ratingsCol(bookId).doc(uid);
    final bookDocRef = _firestore.collection('books').doc(bookId);

    try {
      await _firestore.runTransaction((transaction) async {
        final ratingDocSnap = await transaction.get(ratingDocRef);
        final bookDocSnap = await transaction.get(bookDocRef);

        if (!ratingDocSnap.exists) return; // Nothing to delete

        final double oldRating = (ratingDocSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;
        final String oldReview = (ratingDocSnap.data()?['review'] as String? ?? '');

        transaction.delete(ratingDocRef);

        if (bookDocSnap.exists) {
          final bookData = bookDocSnap.data()!;
          int totalRatings = (bookData['totalRatings'] as int? ?? 0);
          double totalRatingSum = (bookData['totalRatingSum'] as num? ?? 0.0).toDouble();
          int totalReviews = (bookData['totalReviews'] as int? ?? 0);

          totalRatings = (totalRatings - 1).clamp(0, 999999);
          totalRatingSum = (totalRatingSum - oldRating).clamp(0.0, double.infinity);
          if (oldReview.trim().isNotEmpty) {
            totalReviews = (totalReviews - 1).clamp(0, 999999);
          }

          transaction.update(bookDocRef, {
            'totalRatings': totalRatings,
            'totalRatingSum': totalRatingSum,
            'averageRating': totalRatings > 0 ? totalRatingSum / totalRatings : 0.0,
            'totalReviews': totalReviews,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      debugPrint('[RatingService] ❌ deleteRating error: $e');
      rethrow;
    }
  }
}
