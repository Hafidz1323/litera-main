import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Litera'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In id, this message translates to:
  /// **'Baca Kapan Saja, Di Mana Saja'**
  String get appSlogan;

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat Siang'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat Sore'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat Malam'**
  String get greetingNight;

  /// No description provided for @greetingQuestion.
  ///
  /// In id, this message translates to:
  /// **'Mau baca buku apa hari ini?'**
  String get greetingQuestion;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari judul, penulis, atau genre...'**
  String get searchHint;

  /// No description provided for @searchBooksHint.
  ///
  /// In id, this message translates to:
  /// **'Cari buku, penulis...'**
  String get searchBooksHint;

  /// No description provided for @continueReading.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Membaca'**
  String get continueReading;

  /// No description provided for @popularBooks.
  ///
  /// In id, this message translates to:
  /// **'Buku Populer'**
  String get popularBooks;

  /// No description provided for @newReleases.
  ///
  /// In id, this message translates to:
  /// **'Baru Dirilis'**
  String get newReleases;

  /// No description provided for @recommendedForYou.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi Untukmu'**
  String get recommendedForYou;

  /// No description provided for @trending.
  ///
  /// In id, this message translates to:
  /// **'Sedang Trending'**
  String get trending;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get seeAll;

  /// No description provided for @quoteOfTheDay.
  ///
  /// In id, this message translates to:
  /// **'Kutipan Hari Ini'**
  String get quoteOfTheDay;

  /// No description provided for @readingChallenge.
  ///
  /// In id, this message translates to:
  /// **'Target Membaca 2025'**
  String get readingChallenge;

  /// No description provided for @readingChallengeProgress.
  ///
  /// In id, this message translates to:
  /// **'{finished} dari {total} buku selesai'**
  String readingChallengeProgress(int finished, int total);

  /// No description provided for @percentDone.
  ///
  /// In id, this message translates to:
  /// **'{percent}% selesai'**
  String percentDone(int percent);

  /// No description provided for @startReading.
  ///
  /// In id, this message translates to:
  /// **'Mulai Membaca'**
  String get startReading;

  /// No description provided for @continueReadingBtn.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Membaca'**
  String get continueReadingBtn;

  /// No description provided for @previewUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Preview Tidak Tersedia'**
  String get previewUnavailable;

  /// No description provided for @aboutBook.
  ///
  /// In id, this message translates to:
  /// **'Tentang Buku'**
  String get aboutBook;

  /// No description provided for @relatedBooks.
  ///
  /// In id, this message translates to:
  /// **'Buku Terkait'**
  String get relatedBooks;

  /// No description provided for @readMore.
  ///
  /// In id, this message translates to:
  /// **'Baca selengkapnya'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan lebih sedikit'**
  String get showLess;

  /// No description provided for @bookmarked.
  ///
  /// In id, this message translates to:
  /// **'✓ Ditambahkan ke koleksi'**
  String get bookmarked;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In id, this message translates to:
  /// **'Dihapus dari koleksi'**
  String get bookmarkRemoved;

  /// No description provided for @addBookmark.
  ///
  /// In id, this message translates to:
  /// **'Tambah bookmark'**
  String get addBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In id, this message translates to:
  /// **'Hapus bookmark'**
  String get removeBookmark;

  /// No description provided for @myCollection.
  ///
  /// In id, this message translates to:
  /// **'Koleksi Saya'**
  String get myCollection;

  /// No description provided for @emptyCollectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada koleksi'**
  String get emptyCollectionTitle;

  /// No description provided for @emptyCollectionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bookmark buku favorit kamu untuk mulai.'**
  String get emptyCollectionSubtitle;

  /// No description provided for @readingHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Baca'**
  String get readingHistory;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistorySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buka detail buku untuk memulai riwayat membaca.'**
  String get emptyHistorySubtitle;

  /// No description provided for @clearHistory.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua Riwayat'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin menghapus semua riwayat membaca?'**
  String get clearHistoryConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @readingStats.
  ///
  /// In id, this message translates to:
  /// **'Statistik Membaca'**
  String get readingStats;

  /// No description provided for @statBooksRead.
  ///
  /// In id, this message translates to:
  /// **'Buku\nDibaca'**
  String get statBooksRead;

  /// No description provided for @statReadingHours.
  ///
  /// In id, this message translates to:
  /// **'Jam\nMembaca'**
  String get statReadingHours;

  /// No description provided for @statStreak.
  ///
  /// In id, this message translates to:
  /// **'Hari\nBeruntun'**
  String get statStreak;

  /// No description provided for @accountSection.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get accountSection;

  /// No description provided for @appearanceSection.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearanceSection;

  /// No description provided for @otherSection.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get otherSection;

  /// No description provided for @editName.
  ///
  /// In id, this message translates to:
  /// **'Edit Nama'**
  String get editName;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailVerified.
  ///
  /// In id, this message translates to:
  /// **'Email Terverifikasi'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In id, this message translates to:
  /// **'Email Belum Diverifikasi'**
  String get emailNotVerified;

  /// No description provided for @resendVerification.
  ///
  /// In id, this message translates to:
  /// **'Kirim Ulang Verifikasi Email'**
  String get resendVerification;

  /// No description provided for @nameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Tampilan'**
  String get nameLabel;

  /// No description provided for @nameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong'**
  String get nameEmpty;

  /// No description provided for @nameUpdated.
  ///
  /// In id, this message translates to:
  /// **'Nama berhasil diperbarui!'**
  String get nameUpdated;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Tema Gelap'**
  String get darkMode;

  /// No description provided for @darkModeOn.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get darkModeOn;

  /// No description provided for @darkModeOff.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get darkModeOff;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @languageId.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageId;

  /// No description provided for @languageEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @helpCenter.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get helpCenter;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi 1.0.0'**
  String get appVersion;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar Akun'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar Akun?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In id, this message translates to:
  /// **'Kamu akan keluar dari akun Litera-mu. Yakin?'**
  String get logoutConfirmContent;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, Keluar'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @or.
  ///
  /// In id, this message translates to:
  /// **'ATAU'**
  String get or;

  /// No description provided for @errorGeneral.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Silakan coba lagi.'**
  String get errorGeneral;

  /// No description provided for @errorNoInternet.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet. Coba lagi.'**
  String get errorNoInternet;

  /// No description provided for @errorTimeout.
  ///
  /// In id, this message translates to:
  /// **'Waktu koneksi habis. Coba lagi.'**
  String get errorTimeout;

  /// No description provided for @errorNoBooksLoaded.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada buku yang berhasil dimuat. Periksa koneksi internet Anda.'**
  String get errorNoBooksLoaded;

  /// No description provided for @errorNoBooks.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada buku ditemukan.'**
  String get errorNoBooks;

  /// No description provided for @errorLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat buku.'**
  String get errorLoadFailed;

  /// No description provided for @welcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get welcomeBack;

  /// No description provided for @appSlogan2.
  ///
  /// In id, this message translates to:
  /// **'BACA DI MANA SAJA KAPAN SAJA'**
  String get appSlogan2;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// No description provided for @emailEmpty.
  ///
  /// In id, this message translates to:
  /// **'Email tidak boleh kosong'**
  String get emailEmpty;

  /// No description provided for @enterEmailHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email Anda'**
  String get enterEmailHint;

  /// No description provided for @loginSuccess.
  ///
  /// In id, this message translates to:
  /// **'Login berhasil'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In id, this message translates to:
  /// **'Login gagal. Periksa email dan kata sandi Anda.'**
  String get loginError;

  /// No description provided for @orEmail.
  ///
  /// In id, this message translates to:
  /// **'atau lanjutkan dengan email'**
  String get orEmail;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In id, this message translates to:
  /// **'Reset Kata Sandi'**
  String get resetPassword;

  /// No description provided for @noAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? '**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In id, this message translates to:
  /// **'Daftar Sekarang'**
  String get registerNow;

  /// No description provided for @loginTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan membaca'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginButton;

  /// No description provided for @loginWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get loginWithGoogle;

  /// No description provided for @registerLink.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerLink;

  /// No description provided for @loginLink.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginLink;

  /// No description provided for @createAccount.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun'**
  String get createAccount;

  /// No description provided for @joinMessage.
  ///
  /// In id, this message translates to:
  /// **'Bergabung dengan Litera sekarang'**
  String get joinMessage;

  /// No description provided for @fullName.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get alreadyHaveAccount;

  /// No description provided for @iAgreeTo.
  ///
  /// In id, this message translates to:
  /// **'Saya setuju dengan'**
  String get iAgreeTo;

  /// No description provided for @termsAndConditions.
  ///
  /// In id, this message translates to:
  /// **'Syarat & Ketentuan'**
  String get termsAndConditions;

  /// No description provided for @termsDetail.
  ///
  /// In id, this message translates to:
  /// **'Silakan baca dan setujui ketentuan kami sebelum melanjutkan.'**
  String get termsDetail;

  /// No description provided for @termsAgreementError.
  ///
  /// In id, this message translates to:
  /// **'Kamu harus menyetujui ketentuan terlebih dahulu.'**
  String get termsAgreementError;

  /// No description provided for @registrationSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pendaftaran berhasil! Selamat datang di Litera.'**
  String get registrationSuccess;

  /// No description provided for @registerTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bergabung dengan jutaan pembaca'**
  String get registerSubtitle;

  /// No description provided for @registerName.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get registerName;

  /// No description provided for @registerEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi'**
  String get registerConfirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerButton;

  /// No description provided for @hasAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? '**
  String get hasAccount;

  /// No description provided for @dashboardTitle.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get dashboardTitle;

  /// No description provided for @exploreTitle.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi'**
  String get exploreTitle;

  /// No description provided for @categoryAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get categoryAll;

  /// No description provided for @ratingSection.
  ///
  /// In id, this message translates to:
  /// **'Rating & Ulasan'**
  String get ratingSection;

  /// No description provided for @yourRating.
  ///
  /// In id, this message translates to:
  /// **'Beri Rating'**
  String get yourRating;

  /// No description provided for @writeReview.
  ///
  /// In id, this message translates to:
  /// **'Tulis ulasan (opsional)'**
  String get writeReview;

  /// No description provided for @submitRating.
  ///
  /// In id, this message translates to:
  /// **'Kirim Rating'**
  String get submitRating;

  /// No description provided for @updateRating.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Rating'**
  String get updateRating;

  /// No description provided for @ratingSuccess.
  ///
  /// In id, this message translates to:
  /// **'Rating berhasil disimpan!'**
  String get ratingSuccess;

  /// No description provided for @ratingError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan rating.'**
  String get ratingError;

  /// No description provided for @noReviews.
  ///
  /// In id, this message translates to:
  /// **'Belum ada ulasan.'**
  String get noReviews;

  /// No description provided for @sortNewest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get sortNewest;

  /// No description provided for @sortHighest.
  ///
  /// In id, this message translates to:
  /// **'Rating Tertinggi'**
  String get sortHighest;

  /// No description provided for @loginToRate.
  ///
  /// In id, this message translates to:
  /// **'Silakan login untuk memberi rating dan ulasan.'**
  String get loginToRate;

  /// No description provided for @chooseLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa yang ingin kamu gunakan di aplikasi Litera.'**
  String get chooseLanguageSubtitle;

  /// No description provided for @chooseLanguageConfirm.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get chooseLanguageConfirm;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Foto Profil'**
  String get profilePhotoTitle;

  /// No description provided for @camera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @deletePhoto.
  ///
  /// In id, this message translates to:
  /// **'Hapus Foto'**
  String get deletePhoto;

  /// No description provided for @previewPhoto.
  ///
  /// In id, this message translates to:
  /// **'Preview Foto'**
  String get previewPhoto;

  /// No description provided for @useThisPhoto.
  ///
  /// In id, this message translates to:
  /// **'Gunakan foto ini sebagai profil Anda?'**
  String get useThisPhoto;

  /// No description provided for @photoUpdated.
  ///
  /// In id, this message translates to:
  /// **'Foto profil berhasil diperbarui!'**
  String get photoUpdated;

  /// No description provided for @photoDeleted.
  ///
  /// In id, this message translates to:
  /// **'Foto profil dihapus.'**
  String get photoDeleted;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In id, this message translates to:
  /// **'Foto profil Anda akan dihapus dan diganti dengan avatar default.'**
  String get deletePhotoConfirm;

  /// No description provided for @deletePhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Foto?'**
  String get deletePhotoTitle;

  /// No description provided for @verificationSent.
  ///
  /// In id, this message translates to:
  /// **'Email verifikasi telah dikirim!'**
  String get verificationSent;

  /// No description provided for @infoYear.
  ///
  /// In id, this message translates to:
  /// **'Terbit'**
  String get infoYear;

  /// No description provided for @infoPages.
  ///
  /// In id, this message translates to:
  /// **'Halaman'**
  String get infoPages;

  /// No description provided for @infoLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get infoLanguage;

  /// No description provided for @infoGenre.
  ///
  /// In id, this message translates to:
  /// **'Genre'**
  String get infoGenre;

  /// No description provided for @unknownAuthor.
  ///
  /// In id, this message translates to:
  /// **'Penulis Tidak Diketahui'**
  String get unknownAuthor;

  /// No description provided for @unknownCategory.
  ///
  /// In id, this message translates to:
  /// **'Umum'**
  String get unknownCategory;

  /// No description provided for @noTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanpa Judul'**
  String get noTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
