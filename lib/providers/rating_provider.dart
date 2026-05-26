import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/rating_service.dart';

enum RatingSort { newest, highest }

/// Manages rating and review state for a single book's detail page.
/// Supports real-time updates via Streams.
class RatingProvider extends ChangeNotifier {
  final String bookId;

  List<ReviewModel> _reviews = [];
  ReviewModel? _myReview;
  double _average = 0;
  int _totalRatings = 0;
  int _totalReviews = 0;
  
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  RatingSort _sort = RatingSort.newest;

  StreamSubscription? _reviewsSub;
  StreamSubscription? _myReviewSub;

  RatingProvider({required this.bookId}) {
    startListening();
    loadStats();
  }

  @override
  void dispose() {
    _reviewsSub?.cancel();
    _myReviewSub?.cancel();
    super.dispose();
  }

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<ReviewModel> get reviews {
    final list = List<ReviewModel>.from(_reviews);
    if (_sort == RatingSort.highest) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  ReviewModel? get myReview => _myReview;
  double get average => _average;
  int get totalRatings => _totalRatings;
  int get totalReviews => _totalReviews;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  RatingSort get sort => _sort;
  bool get hasMyReview => _myReview != null;

  // ── Realtime ────────────────────────────────────────────────────────────────
  
  void startListening() {
    _isLoading = true;
    notifyListeners();

    // Watch all reviews
    _reviewsSub = RatingService.watchReviews(bookId).listen((data) {
      _reviews = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });

    // Watch current user's review
    _myReviewSub = RatingService.watchMyReview(bookId).listen((data) {
      _myReview = data;
      notifyListeners();
    });
  }

  Future<void> loadStats() async {
    final stats = await RatingService.getStats(bookId);
    _average = stats.average;
    _totalRatings = stats.count;
    _totalReviews = stats.reviews;
    notifyListeners();
  }

  void setSort(RatingSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    notifyListeners();
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  
  Future<bool> submit({required double rating, required String review}) async {
    if (rating <= 0) {
      _error = 'Rating cannot be zero';
      notifyListeners();
      return false;
    }

    debugPrint('[RatingProvider] 📝 Attempting to submit review for $bookId');
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await RatingService.submitRating(
        bookId: bookId,
        rating: rating,
        review: review,
      );
      
      debugPrint('[RatingProvider] ✅ Submit successful, refreshing stats...');
      // Refresh stats manually after write
      await loadStats();
      
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      debugPrint('[RatingProvider] ❌ Submit failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMyRating() async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await RatingService.deleteRating(bookId);
      await loadStats();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
