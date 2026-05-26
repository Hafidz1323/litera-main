import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';

/// Service to handle resolving readable ebook sources from Google Books,
/// Open Library, and Internet Archive.
class EbookSourceService {
  static const String _userAgent = 'LiteraEbookApp/1.0 (contact: ekarizqi.dev@gmail.com)';

  /// Mendapatkan list ia (Internet Archive) ID untuk buku
  static Future<List<String>> _fetchIaIds(BookModel book) async {
    final List<String> iaIds = [];

    // 1. Coba cari dengan ISBN jika tersedia
    if (book.isbn.isNotEmpty) {
      try {
        final isbnClean = book.isbn.replaceAll(RegExp(r'[^0-9X]'), '');
        final url = 'https://openlibrary.org/api/books?bibkeys=ISBN:$isbnClean&jscmd=details&format=json';
        debugPrint('[EbookSourceService] 🔍 Querying Open Library by ISBN: $isbnClean');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': _userAgent},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final key = 'ISBN:$isbnClean';
          if (data.containsKey(key)) {
            final bookData = data[key] as Map<String, dynamic>;
            final details = bookData['details'] as Map<String, dynamic>? ?? {};
            final ia = details['ia'] as List<dynamic>? ?? [];
            for (var id in ia) {
              if (id is String && id.isNotEmpty) {
                iaIds.add(id);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[EbookSourceService] ⚠️ Open Library ISBN query error: $e');
      }
    }

    // 2. Jika tidak ada ISBN atau tidak ada iaIds, coba search dengan Title dan Author
    if (iaIds.isEmpty) {
      try {
        final title = book.title;
        final author = book.authorsDisplay;
        
        // Clean title and author to avoid special char issues in search query
        final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]'), ' ');
        final cleanAuthor = author != 'Penulis Tidak Diketahui' 
            ? author.replaceAll(RegExp(r'[^\w\s]'), ' ') 
            : '';
            
        String query = 'title:($cleanTitle)';
        if (cleanAuthor.isNotEmpty) {
          query += ' AND author:($cleanAuthor)';
        }
        
        final url = 'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=3&fields=ia,title';
        debugPrint('[EbookSourceService] 🔍 Querying Open Library search: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': _userAgent},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final docs = data['docs'] as List<dynamic>? ?? [];
          for (var doc in docs) {
            if (doc is Map<String, dynamic>) {
              final ia = doc['ia'] as List<dynamic>? ?? [];
              for (var id in ia) {
                if (id is String && id.isNotEmpty && !iaIds.contains(id)) {
                  iaIds.add(id);
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[EbookSourceService] ⚠️ Open Library Search query error: $e');
      }
    }

    return iaIds;
  }

  /// Cek validitas URL dengan HEAD request
  static Future<bool> _isUrlValid(String url) async {
    try {
      final response = await http.head(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      // Jika HEAD request gagal atau tidak didukung, coba GET request minimalis
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': _userAgent,
            'Range': 'bytes=0-0', // Request only first byte to save bandwidth
          },
        ).timeout(const Duration(seconds: 3));
        return response.statusCode == 200 || response.statusCode == 206;
      } catch (_) {
        return false;
      }
    }
  }

  /// Resolving URL EPUB dan PDF terbaik untuk buku ini
  static Future<ResolvedSources> resolveSources(BookModel book) async {
    // 1. Google Books PDF (prioritas 1)
    if (book.pdfDownloadLink != null && book.pdfDownloadLink!.isNotEmpty) {
      debugPrint('[EbookSourceService] Found Google Books PDF');
      if (await _isUrlValid(book.pdfDownloadLink!)) {
        return ResolvedSources(
          pdfUrl: book.pdfDownloadLink,
          sourceType: 'Google Books PDF',
        );
      }
    }

    // 2. Google Books EPUB (prioritas 2)
    if (book.epubDownloadLink != null && book.epubDownloadLink!.isNotEmpty) {
      debugPrint('[EbookSourceService] Found Google Books EPUB');
      if (await _isUrlValid(book.epubDownloadLink!)) {
        return ResolvedSources(
          epubUrl: book.epubDownloadLink,
          sourceType: 'Google Books EPUB',
        );
      }
    }

    // Cari Internet Archive IDs
    final iaIds = await _fetchIaIds(book);
    debugPrint('[EbookSourceService] Resolved IA IDs: $iaIds');

    // 3. Open Library / Internet Archive EPUB (prioritas 3)
    for (var iaId in iaIds) {
      final epubUrl = 'https://archive.org/download/$iaId/$iaId.epub';
      if (await _isUrlValid(epubUrl)) {
        debugPrint('[EbookSourceService] Found Open Library EPUB: $epubUrl');
        return ResolvedSources(
          epubUrl: epubUrl,
          sourceType: 'Open Library EPUB',
        );
      }
    }

    // 4. Open Library / Internet Archive PDF (prioritas 4)
    for (var iaId in iaIds) {
      final pdfUrl = 'https://archive.org/download/$iaId/$iaId.pdf';
      if (await _isUrlValid(pdfUrl)) {
        debugPrint('[EbookSourceService] Found Open Library PDF: $pdfUrl');
        return ResolvedSources(
          pdfUrl: pdfUrl,
          sourceType: 'Open Library PDF',
        );
      }
    }

    // 5. webReaderLink (prioritas 5)
    if (book.hasWebReader) {
      return ResolvedSources(
        webUrl: book.webReaderLink,
        sourceType: 'Web Reader',
      );
    }

    // 6. previewLink (prioritas 6)
    if (book.hasPreview) {
      return ResolvedSources(
        webUrl: book.previewLink,
        sourceType: 'Preview',
      );
    }

    return ResolvedSources(sourceType: 'None');
  }
}

class ResolvedSources {
  final String? pdfUrl;
  final String? epubUrl;
  final String? webUrl;
  final String sourceType;

  ResolvedSources({
    this.pdfUrl,
    this.epubUrl,
    this.webUrl,
    required this.sourceType,
  });

  bool get isNative => pdfUrl != null || epubUrl != null;
  bool get isWeb => webUrl != null;
}
