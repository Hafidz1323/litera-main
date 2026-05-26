import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk data buku dari Google Books API
class BookModel {
  final String id;
  final String title;
  final String subtitle;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final int pageCount;
  final List<String> categories;
  final double averageRating;
  final int ratingsCount;
  final String language;
  final String previewLink;
  final String infoLink;
  final String? smallThumbnail;
  final String? thumbnail;
  final bool isEbook;
  final String? buyLink;
  final String? webReaderLink;
  final String? pdfDownloadLink;
  final String? epubDownloadLink;
  final DateTime? createdAt;
  final String isbn;

  const BookModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.authors = const [],
    this.publisher = '',
    this.publishedDate = '',
    this.description = '',
    this.pageCount = 0,
    this.categories = const [],
    this.averageRating = 0.0,
    this.ratingsCount = 0,
    this.language = '',
    this.previewLink = '',
    this.infoLink = '',
    this.smallThumbnail,
    this.thumbnail,
    this.isEbook = false,
    this.buyLink,
    this.webReaderLink,
    this.pdfDownloadLink,
    this.epubDownloadLink,
    this.createdAt,
    this.isbn = '',
  });

  /// Parse dari Google Books API JSON item
  factory BookModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};
    final accessInfo = json['accessInfo'] as Map<String, dynamic>? ?? {};
    final saleInfo = json['saleInfo'] as Map<String, dynamic>? ?? {};
    final pdf = accessInfo['pdf'] as Map<String, dynamic>? ?? {};
    final epub = accessInfo['epub'] as Map<String, dynamic>? ?? {};

    // Ambil ISBN dari industryIdentifiers
    final industryIdentifiers = volumeInfo['industryIdentifiers'] as List<dynamic>? ?? [];
    String isbn = '';
    for (var ident in industryIdentifiers) {
      if (ident is Map<String, dynamic>) {
        final type = ident['type'] as String?;
        final val = ident['identifier'] as String?;
        if (val != null) {
          if (type == 'ISBN_13') {
            isbn = val;
            break;
          } else if (type == 'ISBN_10') {
            isbn = val;
          }
        }
      }
    }

    // Fix https untuk thumbnail
    String? fixUrl(String? url) {
      if (url == null) return null;
      return url.replaceFirst('http://', 'https://');
    }

    return BookModel(
      id: id,
      title: volumeInfo['title'] as String? ?? 'Tanpa Judul',
      subtitle: volumeInfo['subtitle'] as String? ?? '',
      authors: List<String>.from(volumeInfo['authors'] as List? ?? []),
      publisher: volumeInfo['publisher'] as String? ?? '',
      publishedDate: volumeInfo['publishedDate'] as String? ?? '',
      description: volumeInfo['description'] as String? ?? '',
      pageCount: volumeInfo['pageCount'] as int? ?? 0,
      categories: List<String>.from(volumeInfo['categories'] as List? ?? []),
      averageRating: (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: volumeInfo['ratingsCount'] as int? ?? 0,
      language: volumeInfo['language'] as String? ?? '',
      previewLink: fixUrl(volumeInfo['previewLink'] as String?) ?? '',
      infoLink: fixUrl(volumeInfo['infoLink'] as String?) ?? '',
      smallThumbnail: fixUrl(imageLinks['smallThumbnail'] as String?),
      thumbnail: fixUrl(imageLinks['thumbnail'] as String?),
      isEbook: saleInfo['isEbook'] as bool? ?? false,
      buyLink: fixUrl(saleInfo['buyLink'] as String?),
      webReaderLink: fixUrl(accessInfo['webReaderLink'] as String?),
      pdfDownloadLink: pdf['isAvailable'] == true
          ? fixUrl(pdf['downloadLink'] as String?)
          : null,
      epubDownloadLink: epub['isAvailable'] == true
          ? fixUrl(epub['downloadLink'] as String?)
          : null,
      createdAt: DateTime.now(),
      isbn: isbn,
    );
  }

  /// Serialize ke Map untuk Firestore
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'authors': authors,
        'publisher': publisher,
        'publishedDate': publishedDate,
        'description': description,
        'pageCount': pageCount,
        'categories': categories,
        'averageRating': averageRating,
        'ratingsCount': ratingsCount,
        'language': language,
        'previewLink': previewLink,
        'infoLink': infoLink,
        'smallThumbnail': smallThumbnail,
        'thumbnail': thumbnail,
        'isEbook': isEbook,
        'buyLink': buyLink,
        'webReaderLink': webReaderLink,
        'pdfDownloadLink': pdfDownloadLink,
        'epubDownloadLink': epubDownloadLink,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'isbn': isbn,
      };

  /// Restore dari Firestore Map
  factory BookModel.fromFirestore(Map<String, dynamic> data, [String? docId]) => BookModel(
        id: docId ?? (data['id'] as String? ?? ''),
        title: data['title'] as String? ?? '',
        subtitle: data['subtitle'] as String? ?? '',
        authors: List<String>.from(data['authors'] as List? ?? []),
        publisher: data['publisher'] as String? ?? '',
        publishedDate: data['publishedDate'] as String? ?? '',
        description: data['description'] as String? ?? '',
        pageCount: data['pageCount'] as int? ?? 0,
        categories: List<String>.from(data['categories'] as List? ?? []),
        averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
        ratingsCount: data['ratingsCount'] as int? ?? 0,
        language: data['language'] as String? ?? '',
        previewLink: data['previewLink'] as String? ?? '',
        infoLink: data['infoLink'] as String? ?? '',
        smallThumbnail: data['smallThumbnail'] as String?,
        thumbnail: data['thumbnail'] as String?,
        isEbook: data['isEbook'] as bool? ?? false,
        buyLink: data['buyLink'] as String?,
        webReaderLink: data['webReaderLink'] as String?,
        pdfDownloadLink: data['pdfDownloadLink'] as String?,
        epubDownloadLink: data['epubDownloadLink'] as String?,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        isbn: data['isbn'] as String? ?? '',
      );

  /// Display author string
  String get authorsDisplay =>
      authors.isEmpty ? 'Penulis Tidak Diketahui' : authors.join(', ');

  /// Display category string
  String get categoryDisplay =>
      categories.isEmpty ? 'Umum' : categories.first;

  /// Apakah bisa dibaca online
  bool get hasPreview => previewLink.isNotEmpty;

  /// Apakah ada web reader
  bool get hasWebReader => webReaderLink != null && webReaderLink!.isNotEmpty;

  /// Cover URL terbaik
  String? get bestCover => thumbnail ?? smallThumbnail;

  /// Tahun terbit
  String get year => publishedDate.length >= 4
      ? publishedDate.substring(0, 4)
      : publishedDate;
}
