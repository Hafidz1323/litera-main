/// App-wide constants: preference keys, API config, UI limits.
abstract final class AppConstants {
  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLocale = 'pref_locale';
  static const String prefLanguageSelected = 'pref_language_selected';

  // ── Admin Config ────────────────────────────────────────────────────────────
  static const List<String> adminEmails = [
    'adminlitera@gmail.com',
  ];

  // ── Google Books API ───────────────────────────────────────────────────────
  static const String booksApiBase = 'https://www.googleapis.com/books/v1/volumes';
  static const String booksApiKey = 'AIzaSyCqMloMeoXcQd6npLA3QbIIYitqel88NBY';
  static const int booksDefaultMax = 20;
  static const int booksPageSize = 20;
  static const Duration booksTimeout = Duration(seconds: 20);
  static const Duration booksRetryDelay = Duration(seconds: 2);

  // ── Firestore collections ──────────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colBookmarks = 'bookmarks';
  static const String colReadingHistory = 'reading_history';
  static const String colRatings = 'ratings';

  // ── Reading challenge ──────────────────────────────────────────────────────
  static const int readingChallengeTarget = 12;

  // ── UI ─────────────────────────────────────────────────────────────────────
  static const double borderRadiusCard = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double pagePadding = 20.0;
  static const double sectionSpacing = 32.0;

  // ── Supported locales ──────────────────────────────────────────────────────
  static const String localeId = 'id';
  static const String localeEn = 'en';
  static const String defaultLocale = localeId;

  // ── Quotes (shown on dashboard) ────────────────────────────────────────────
  static const List<Map<String, String>> quotes = [
    {
      'id': '"Buku adalah cermin; kamu hanya melihat di dalamnya apa yang sudah ada dalam dirimu."',
      'en': '"A book is a mirror; you only see in it what is already inside you."',
      'author': 'Carlos Ruiz Zafón',
    },
    {
      'id': '"Membaca adalah mimpi yang kamu kendalikan."',
      'en': '"Reading is a dream you control."',
      'author': 'Unknown',
    },
    {
      'id': '"Sebuah buku yang telah dibaca dengan baik adalah sahabat yang paling setia."',
      'en': '"A book read with care is the most faithful companion."',
      'author': 'Unknown',
    },
    {
      'id': '"Investasi terbaik adalah pada dirimu sendiri; baca sebanyak mungkin."',
      'en': '"The best investment is in yourself; read as much as you can."',
      'author': 'Unknown',
    },
  ];
}
