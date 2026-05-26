import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../pages/book_reader_page.dart';
import '../pages/reader_page.dart';
import 'google_books_service.dart';
import 'reading_history_service.dart';
import 'cache_service.dart';
import 'ebook_source_service.dart';
import 'local_book_service.dart';


class BookService {
  /// Mendapatkan link yang bisa dibaca (PDF atau EPUB)
  /// Prioritas: PDF > EPUB
  static String? getReadableLink(BookModel book) {
    if (book.pdfDownloadLink != null && book.pdfDownloadLink!.isNotEmpty) {
      return book.pdfDownloadLink;
    }
    if (book.epubDownloadLink != null && book.epubDownloadLink!.isNotEmpty) {
      return book.epubDownloadLink;
    }
    return null;
  }

  /// Mengecek apakah buku bisa dibaca di dalam aplikasi
  static bool isReadable(BookModel book) {
    return getReadableLink(book) != null || book.isbn.isNotEmpty || book.title.isNotEmpty;
  }

  /// Menangani aksi baca buku
  static Future<void> openBook(BuildContext context, BookModel book) async {
    // Intersep untuk buku lokal (berdasarkan ID atau kecocokan Judul)
    BookModel? matchedLocalBook;
    if (book.id.startsWith('local_')) {
      matchedLocalBook = book;
    } else {
      matchedLocalBook = LocalBookService.findLocalBookByTitle(book.title);
    }

    if (matchedLocalBook != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            margin: EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2D5A41)),
                  SizedBox(height: 20),
                  Text(
                    'Membuka buku lokal...',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menyiapkan isi buku...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        final assetPath = matchedLocalBook.pdfDownloadLink ?? '';
        final file = await CacheService.extractAssetBook(matchedLocalBook.id, assetPath);
        if (!context.mounted) return;
        Navigator.pop(context); // Tutup dialog loading
        
        _navigateToNativeReader(context, matchedLocalBook, localPath: file.path, isPdf: true);
        return;
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Tutup dialog loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengekstrak isi buku: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    // 1. Cek cache lokal terlebih dahulu
    final cachedFile = await CacheService.getCachedBook(book.id);
    
    if (cachedFile != null) {
      debugPrint('[BookService] 📂 Opening cached file: ${cachedFile.path}');
      final isPdf = cachedFile.path.toLowerCase().endsWith('.pdf');
      if (context.mounted) {
        _navigateToNativeReader(context, book, localPath: cachedFile.path, isPdf: isPdf);
      }
      return;
    }


    // 2. Jika tidak ada cache, tampilkan dialog loading untuk mencari sumber
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          margin: EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF2D5A41)),
                SizedBox(height: 20),
                Text(
                  'Mencari sumber buku...',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Memeriksa PDF/EPUB...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final sources = await EbookSourceService.resolveSources(book);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Tutup dialog loading

      if (sources.isNative) {
        final isPdf = sources.pdfUrl != null;
        final url = sources.pdfUrl ?? sources.epubUrl!;
        debugPrint('[BookService] 📖 Opening native reader (${sources.sourceType}): $url');
        _navigateToNativeReader(
          context, 
          book, 
          remoteUrl: url, 
          isPdf: isPdf,
        );
      } else if (sources.isWeb) {
        // Fallback ke Web Reader / Preview via ReaderPage
        debugPrint('[BookService] 🌐 No direct link, falling back to web reader: ${sources.webUrl}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderPage(book: book),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buku ini tidak memiliki format digital yang didukung.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[BookService] ❌ Error opening book: $e');
      if (context.mounted) {
        Navigator.pop(context); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat sumber buku: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Helper untuk navigasi ke native reader
  static void _navigateToNativeReader(
    BuildContext context, 
    BookModel book, 
    {String? localPath, String? remoteUrl, bool isPdf = true}
  ) {
    // Update history
    ReadingHistoryService.recordBookOpen(book);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookReaderPage(
          book: book,
          localPath: localPath,
          remoteUrl: remoteUrl,
          isPdf: isPdf,
        ),
      ),
    );
  }

  /// Membuka buku berdasarkan ID (untuk riwayat/bookmark)
  static Future<void> openBookById(BuildContext context, String bookId) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final book = await GoogleBooksService.getBookById(bookId);
      if (!context.mounted) return;
      Navigator.pop(context); // Tutup loading

      if (book != null) {
        await openBook(context, book);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data buku.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }
}
