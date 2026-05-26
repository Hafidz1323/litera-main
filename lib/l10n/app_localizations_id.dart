// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Litera';

  @override
  String get appSlogan => 'Baca Kapan Saja, Di Mana Saja';

  @override
  String get greetingMorning => 'Selamat Pagi';

  @override
  String get greetingAfternoon => 'Selamat Siang';

  @override
  String get greetingEvening => 'Selamat Sore';

  @override
  String get greetingNight => 'Selamat Malam';

  @override
  String get greetingQuestion => 'Mau baca buku apa hari ini?';

  @override
  String get searchHint => 'Cari judul, penulis, atau genre...';

  @override
  String get searchBooksHint => 'Cari buku, penulis...';

  @override
  String get continueReading => 'Lanjutkan Membaca';

  @override
  String get popularBooks => 'Buku Populer';

  @override
  String get newReleases => 'Baru Dirilis';

  @override
  String get recommendedForYou => 'Rekomendasi Untukmu';

  @override
  String get trending => 'Sedang Trending';

  @override
  String get seeAll => 'Lihat semua';

  @override
  String get quoteOfTheDay => 'Kutipan Hari Ini';

  @override
  String get readingChallenge => 'Target Membaca 2025';

  @override
  String readingChallengeProgress(int finished, int total) {
    return '$finished dari $total buku selesai';
  }

  @override
  String percentDone(int percent) {
    return '$percent% selesai';
  }

  @override
  String get startReading => 'Mulai Membaca';

  @override
  String get continueReadingBtn => 'Lanjut Membaca';

  @override
  String get previewUnavailable => 'Preview Tidak Tersedia';

  @override
  String get aboutBook => 'Tentang Buku';

  @override
  String get relatedBooks => 'Buku Terkait';

  @override
  String get readMore => 'Baca selengkapnya';

  @override
  String get showLess => 'Tampilkan lebih sedikit';

  @override
  String get bookmarked => '✓ Ditambahkan ke koleksi';

  @override
  String get bookmarkRemoved => 'Dihapus dari koleksi';

  @override
  String get addBookmark => 'Tambah bookmark';

  @override
  String get removeBookmark => 'Hapus bookmark';

  @override
  String get myCollection => 'Koleksi Saya';

  @override
  String get emptyCollectionTitle => 'Belum ada koleksi';

  @override
  String get emptyCollectionSubtitle =>
      'Bookmark buku favorit kamu untuk mulai.';

  @override
  String get readingHistory => 'Riwayat Baca';

  @override
  String get emptyHistoryTitle => 'Belum ada riwayat';

  @override
  String get emptyHistorySubtitle =>
      'Buka detail buku untuk memulai riwayat membaca.';

  @override
  String get clearHistory => 'Hapus Semua Riwayat';

  @override
  String get clearHistoryConfirm =>
      'Yakin ingin menghapus semua riwayat membaca?';

  @override
  String get profileTitle => 'Profil';

  @override
  String get readingStats => 'Statistik Membaca';

  @override
  String get statBooksRead => 'Buku\nDibaca';

  @override
  String get statReadingHours => 'Jam\nMembaca';

  @override
  String get statStreak => 'Hari\nBeruntun';

  @override
  String get accountSection => 'Akun';

  @override
  String get appearanceSection => 'Tampilan';

  @override
  String get otherSection => 'Lainnya';

  @override
  String get editName => 'Edit Nama';

  @override
  String get email => 'Email';

  @override
  String get emailVerified => 'Email Terverifikasi';

  @override
  String get emailNotVerified => 'Email Belum Diverifikasi';

  @override
  String get resendVerification => 'Kirim Ulang Verifikasi Email';

  @override
  String get nameLabel => 'Nama Tampilan';

  @override
  String get nameEmpty => 'Nama tidak boleh kosong';

  @override
  String get nameUpdated => 'Nama berhasil diperbarui!';

  @override
  String get darkMode => 'Tema Gelap';

  @override
  String get darkModeOn => 'Aktif';

  @override
  String get darkModeOff => 'Nonaktif';

  @override
  String get language => 'Bahasa';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageEn => 'English';

  @override
  String get helpCenter => 'Pusat Bantuan';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get appVersion => 'Versi 1.0.0';

  @override
  String get logout => 'Keluar Akun';

  @override
  String get logoutConfirmTitle => 'Keluar Akun?';

  @override
  String get logoutConfirmContent =>
      'Kamu akan keluar dari akun Litera-mu. Yakin?';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Ya, Keluar';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get loading => 'Memuat...';

  @override
  String get or => 'ATAU';

  @override
  String get errorGeneral => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get errorNoInternet => 'Tidak ada koneksi internet. Coba lagi.';

  @override
  String get errorTimeout => 'Waktu koneksi habis. Coba lagi.';

  @override
  String get errorNoBooksLoaded =>
      'Tidak ada buku yang berhasil dimuat. Periksa koneksi internet Anda.';

  @override
  String get errorNoBooks => 'Tidak ada buku ditemukan.';

  @override
  String get errorLoadFailed => 'Gagal memuat buku.';

  @override
  String get welcomeBack => 'Selamat Datang';

  @override
  String get appSlogan2 => 'BACA DI MANA SAJA KAPAN SAJA';

  @override
  String get login => 'Masuk';

  @override
  String get password => 'Kata Sandi';

  @override
  String get emailEmpty => 'Email tidak boleh kosong';

  @override
  String get enterEmailHint => 'Masukkan email Anda';

  @override
  String get loginSuccess => 'Login berhasil';

  @override
  String get loginError => 'Login gagal. Periksa email dan kata sandi Anda.';

  @override
  String get orEmail => 'atau lanjutkan dengan email';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get resetPassword => 'Reset Kata Sandi';

  @override
  String get noAccount => 'Belum punya akun? ';

  @override
  String get registerNow => 'Daftar Sekarang';

  @override
  String get loginTitle => 'Selamat Datang';

  @override
  String get loginSubtitle => 'Masuk untuk melanjutkan membaca';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Kata Sandi';

  @override
  String get loginButton => 'Masuk';

  @override
  String get loginWithGoogle => 'Masuk dengan Google';

  @override
  String get registerLink => 'Daftar';

  @override
  String get loginLink => 'Masuk';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get joinMessage => 'Bergabung dengan Litera sekarang';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun?';

  @override
  String get iAgreeTo => 'Saya setuju dengan';

  @override
  String get termsAndConditions => 'Syarat & Ketentuan';

  @override
  String get termsDetail =>
      'Silakan baca dan setujui ketentuan kami sebelum melanjutkan.';

  @override
  String get termsAgreementError =>
      'Kamu harus menyetujui ketentuan terlebih dahulu.';

  @override
  String get registrationSuccess =>
      'Pendaftaran berhasil! Selamat datang di Litera.';

  @override
  String get registerTitle => 'Buat Akun';

  @override
  String get registerSubtitle => 'Bergabung dengan jutaan pembaca';

  @override
  String get registerName => 'Nama Lengkap';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Kata Sandi';

  @override
  String get registerConfirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get registerButton => 'Daftar';

  @override
  String get hasAccount => 'Sudah punya akun? ';

  @override
  String get dashboardTitle => 'Beranda';

  @override
  String get exploreTitle => 'Jelajahi';

  @override
  String get categoryAll => 'Semua';

  @override
  String get ratingSection => 'Rating & Ulasan';

  @override
  String get yourRating => 'Beri Rating';

  @override
  String get writeReview => 'Tulis ulasan (opsional)';

  @override
  String get submitRating => 'Kirim Rating';

  @override
  String get updateRating => 'Perbarui Rating';

  @override
  String get ratingSuccess => 'Rating berhasil disimpan!';

  @override
  String get ratingError => 'Gagal menyimpan rating.';

  @override
  String get noReviews => 'Belum ada ulasan.';

  @override
  String get sortNewest => 'Terbaru';

  @override
  String get sortHighest => 'Rating Tertinggi';

  @override
  String get loginToRate => 'Silakan login untuk memberi rating dan ulasan.';

  @override
  String get chooseLanguage => 'Pilih Bahasa';

  @override
  String get chooseLanguageSubtitle =>
      'Pilih bahasa yang ingin kamu gunakan di aplikasi Litera.';

  @override
  String get chooseLanguageConfirm => 'Mulai';

  @override
  String get profilePhotoTitle => 'Pilih Foto Profil';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get deletePhoto => 'Hapus Foto';

  @override
  String get previewPhoto => 'Preview Foto';

  @override
  String get useThisPhoto => 'Gunakan foto ini sebagai profil Anda?';

  @override
  String get photoUpdated => 'Foto profil berhasil diperbarui!';

  @override
  String get photoDeleted => 'Foto profil dihapus.';

  @override
  String get deletePhotoConfirm =>
      'Foto profil Anda akan dihapus dan diganti dengan avatar default.';

  @override
  String get deletePhotoTitle => 'Hapus Foto?';

  @override
  String get verificationSent => 'Email verifikasi telah dikirim!';

  @override
  String get infoYear => 'Terbit';

  @override
  String get infoPages => 'Halaman';

  @override
  String get infoLanguage => 'Bahasa';

  @override
  String get infoGenre => 'Genre';

  @override
  String get unknownAuthor => 'Penulis Tidak Diketahui';

  @override
  String get unknownCategory => 'Umum';

  @override
  String get noTitle => 'Tanpa Judul';
}
