import '../models/book_model.dart';

class LocalBookService {
  static final List<BookModel> localBooks = [
    BookModel(
      id: 'local_cantik_itu_luka',
      title: 'Cantik Itu Luka',
      authors: ['Eka Kurniawan'],
      publisher: 'Gramedia Pustaka Utama',
      publishedDate: '2002-03-01',
      description: 'Cantik itu Luka, novel pertama Eka Kurniawan, berkisah tentang Dewi Ayu, seorang pelacur legendaris di zaman akhir kolonial, dan anak-anak perempuannya yang cantik namun dikutuk oleh kecantikan mereka.',
      pageCount: 508,
      categories: ['Sastra Indo', 'Novel'],
      averageRating: 4.8,
      ratingsCount: 120,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://covers.openlibrary.org/b/id/12836245-L.jpg',
      pdfDownloadLink: 'assets/books/cantik_itu_luka.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_ronggeng_dukuh_paruk',
      title: 'Ronggeng Dukuh Paruk',
      authors: ['Ahmad Tohari'],
      publisher: 'Gramedia Pustaka Utama',
      publishedDate: '1982-01-01',
      description: 'Ronggeng Dukuh Paruk adalah sebuah novel yang menceritakan kehidupan Srintil, seorang penari ronggeng di sebuah dusun terpencil bernama Dukuh Paruk yang penuh dengan tradisi dan tragedi politik.',
      pageCount: 408,
      categories: ['Sastra Indo', 'Novel'],
      averageRating: 4.7,
      ratingsCount: 95,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://covers.openlibrary.org/b/id/8315183-L.jpg',
      pdfDownloadLink: 'assets/books/ronggeng_dukuh_paruk.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_sejarah_disembunyikan',
      title: 'Sejarah Dunia yang Disembunyikan',
      authors: ['Jonathan Black'],
      publisher: 'Pustaka Alvabet',
      publishedDate: '2007-01-01',
      description: 'Jonathan Black mengupas misteri dan sejarah alternatif dunia dari perspektif berbagai perkumpulan rahasia dan ajaran esoterik sejak zaman dahulu kala.',
      pageCount: 636,
      categories: ['Sejarah'],
      averageRating: 4.6,
      ratingsCount: 88,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://covers.openlibrary.org/b/id/10515159-L.jpg',
      pdfDownloadLink: 'assets/books/sejarah_disembunyikan.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_thermodynamics',
      title: 'Fundamentals of Engineering Thermodynamics',
      authors: ['Michael J. Moran', 'Howard N. Shapiro', 'Daisie D. Boettner', 'Margaret B. Bailey'],
      publisher: 'Wiley',
      publishedDate: '2014-01-01',
      description: 'The classic textbook on engineering thermodynamics, providing a comprehensive and detailed explanation of thermodynamic principles.',
      pageCount: 1024,
      categories: ['Teknologi', 'Sains'],
      averageRating: 4.5,
      ratingsCount: 42,
      language: 'en',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://covers.openlibrary.org/b/isbn/9781118412930-L.jpg',
      pdfDownloadLink: 'assets/books/thermodynamics.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_konflik_kolaborasi',
      title: 'Konflik dan Kolaborasi: Peran Negara dalam Integrasi Bangsa',
      authors: ['Kementerian Pendidikan dan Kebudayaan'],
      publisher: 'Kemendikbud',
      publishedDate: '2021-01-01',
      description: 'Buku ini membahas mengenai konflik dan kolaborasi serta peran penting negara dalam upaya membangun integrasi bangsa Indonesia.',
      pageCount: 120,
      categories: ['Sejarah Indo', 'Edukasi'],
      averageRating: 4.4,
      ratingsCount: 30,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://img.freepik.com/free-vector/polygonal-indonesian-map-design_23-2148412586.jpg',
      pdfDownloadLink: 'assets/books/konflik_kolaborasi.pdf',
      isEbook: true,
    ),
    BookModel(
      id: 'local_broken_strings',
      title: 'Broken Strings',
      authors: ['Idn'],
      publisher: 'Litera Publisher',
      publishedDate: '2023-01-01',
      description: 'Kisah romansa penuh intrik dan perjuangan emosional yang menyentuh hati para pembaca.',
      pageCount: 280,
      categories: ['Novel', 'Romance'],
      averageRating: 4.5,
      ratingsCount: 54,
      language: 'id',
      previewLink: '',
      infoLink: '',
      thumbnail: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400',
      pdfDownloadLink: 'assets/books/broken_strings.pdf',
      isEbook: true,
    ),
  ];

  /// Get books matching category
  static List<BookModel> getBooksByCategory(String category) {
    if (category == 'Semua') return localBooks;
    final catLower = category.toLowerCase();
    
    return localBooks.where((book) {
      return book.categories.any((c) => c.toLowerCase().contains(catLower)) ||
             (category == 'Sastra Indo' && book.categories.contains('Sastra Indo')) ||
             (category == 'Sejarah Indo' && book.categories.contains('Sejarah Indo')) ||
             (category == 'Novel' && book.categories.contains('Novel')) ||
             (category == 'Teknologi' && book.categories.contains('Teknologi')) ||
             (category == 'Sejarah' && book.categories.contains('Sejarah'));
    }).toList();
  }

  /// Search local books
  static List<BookModel> searchBooks(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return localBooks.where((book) {
      return book.title.toLowerCase().contains(q) ||
             book.authorsDisplay.toLowerCase().contains(q) ||
             book.categories.any((c) => c.toLowerCase().contains(q));
    }).toList();
  }

  /// Find local book by matching title (case-insensitive, substring)
  static BookModel? findLocalBookByTitle(String title) {
    final cleanTitle = title.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    if (cleanTitle.isEmpty) return null;
    for (var book in localBooks) {
      final bookClean = book.title.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      if (cleanTitle.contains(bookClean) || bookClean.contains(cleanTitle)) {
        return book;
      }
    }
    return null;
  }
}

