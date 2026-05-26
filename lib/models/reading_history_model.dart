import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk riwayat membaca yang disimpan di Firestore
class ReadingHistoryModel {
  final String bookId;
  final String title;
  final String authors;
  final String? thumbnail;
  final double progress; // 0.0 - 1.0
  final int lastPage;
  final int totalPages;
  final DateTime lastReadAt;
  final DateTime addedAt;

  const ReadingHistoryModel({
    required this.bookId,
    required this.title,
    required this.authors,
    this.thumbnail,
    required this.progress,
    required this.lastPage,
    required this.totalPages,
    required this.lastReadAt,
    required this.addedAt,
  });

  /// Serialize ke Firestore
  Map<String, dynamic> toFirestore() => {
        'bookId': bookId,
        'title': title,
        'authors': authors,
        'thumbnail': thumbnail,
        'progress': progress,
        'lastPage': lastPage,
        'totalPages': totalPages,
        'lastReadAt': Timestamp.fromDate(lastReadAt),
        'addedAt': Timestamp.fromDate(addedAt),
      };

  /// Restore dari Firestore document
  factory ReadingHistoryModel.fromFirestore(Map<String, dynamic> data) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return ReadingHistoryModel(
      bookId: data['bookId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      authors: data['authors'] as String? ?? '',
      thumbnail: data['thumbnail'] as String?,
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      lastPage: data['lastPage'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 0,
      lastReadAt: parseDate(data['lastReadAt']),
      addedAt: parseDate(data['addedAt']),
    );
  }

  /// Salin dengan nilai baru
  ReadingHistoryModel copyWith({
    double? progress,
    int? lastPage,
    DateTime? lastReadAt,
  }) =>
      ReadingHistoryModel(
        bookId: bookId,
        title: title,
        authors: authors,
        thumbnail: thumbnail,
        progress: progress ?? this.progress,
        lastPage: lastPage ?? this.lastPage,
        totalPages: totalPages,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        addedAt: addedAt,
      );

  /// Persentase selesai (0-100)
  int get progressPercent => (progress * 100).clamp(0, 100).toInt();

  /// Apakah selesai dibaca
  bool get isFinished => progress >= 1.0;
}
