import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single user rating and optional review for a book.
class ReviewModel {
  final String id; // Firestore doc ID (same as userId for 1-per-user)
  final String userId;
  final String userName;
  final String? userPhoto; // Renamed from userPhotoUrl as requested
  final String bookId;
  final double rating; // 1–5
  final String review; // optional comment
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.bookId,
    required this.rating,
    this.review = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String docId) {
    // Handle Firestore server timestamp (local vs server)
    final ts = data['createdAt'];
    DateTime createdAt;
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    } else {
      // Fallback for pending server timestamp
      createdAt = DateTime.now();
    }

    return ReviewModel(
      id: docId,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Pengguna',
      userPhoto: data['userPhoto'] as String?,
      bookId: data['bookId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      review: data['review'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'bookId': bookId,
        'rating': rating,
        'review': review,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  ReviewModel copyWith({
    double? rating,
    String? review,
    DateTime? updatedAt,
  }) =>
      ReviewModel(
        id: id,
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        bookId: bookId,
        rating: rating ?? this.rating,
        review: review ?? this.review,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
