// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Litera';

  @override
  String get appSlogan => 'Read Anywhere, Anytime';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get greetingNight => 'Good Night';

  @override
  String get greetingQuestion => 'What book will you read today?';

  @override
  String get searchHint => 'Search title, author, or genre...';

  @override
  String get searchBooksHint => 'Search books, authors...';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get popularBooks => 'Popular Books';

  @override
  String get newReleases => 'New Releases';

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get trending => 'Trending Now';

  @override
  String get seeAll => 'See all';

  @override
  String get quoteOfTheDay => 'Quote of the Day';

  @override
  String get readingChallenge => '2025 Reading Challenge';

  @override
  String readingChallengeProgress(int finished, int total) {
    return '$finished of $total books done';
  }

  @override
  String percentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get startReading => 'Start Reading';

  @override
  String get continueReadingBtn => 'Continue Reading';

  @override
  String get previewUnavailable => 'Preview Not Available';

  @override
  String get aboutBook => 'About this Book';

  @override
  String get relatedBooks => 'Related Books';

  @override
  String get readMore => 'Read more';

  @override
  String get showLess => 'Show less';

  @override
  String get bookmarked => '✓ Added to collection';

  @override
  String get bookmarkRemoved => 'Removed from collection';

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get myCollection => 'My Collection';

  @override
  String get emptyCollectionTitle => 'No collection yet';

  @override
  String get emptyCollectionSubtitle =>
      'Bookmark your favourite books to get started.';

  @override
  String get readingHistory => 'Reading History';

  @override
  String get emptyHistoryTitle => 'No history yet';

  @override
  String get emptyHistorySubtitle =>
      'Open a book detail to start your reading history.';

  @override
  String get clearHistory => 'Clear All History';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to clear all reading history?';

  @override
  String get profileTitle => 'Profile';

  @override
  String get readingStats => 'Reading Stats';

  @override
  String get statBooksRead => 'Books\nRead';

  @override
  String get statReadingHours => 'Reading\nHours';

  @override
  String get statStreak => 'Day\nStreak';

  @override
  String get accountSection => 'Account';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get otherSection => 'Other';

  @override
  String get editName => 'Edit Name';

  @override
  String get email => 'Email';

  @override
  String get emailVerified => 'Email Verified';

  @override
  String get emailNotVerified => 'Email Not Verified';

  @override
  String get resendVerification => 'Resend Verification Email';

  @override
  String get nameLabel => 'Display Name';

  @override
  String get nameEmpty => 'Name cannot be empty';

  @override
  String get nameUpdated => 'Name updated successfully!';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeOn => 'On';

  @override
  String get darkModeOff => 'Off';

  @override
  String get language => 'Language';

  @override
  String get languageId => 'Bahasa Indonesia';

  @override
  String get languageEn => 'English';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get aboutApp => 'About App';

  @override
  String get appVersion => 'Version 1.0.0';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirmTitle => 'Sign Out?';

  @override
  String get logoutConfirmContent =>
      'You will be signed out of your Litera account. Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Sign Out';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get or => 'OR';

  @override
  String get errorGeneral => 'Something went wrong. Please try again.';

  @override
  String get errorNoInternet => 'No internet connection. Please try again.';

  @override
  String get errorTimeout => 'Connection timed out. Please try again.';

  @override
  String get errorNoBooksLoaded =>
      'No books could be loaded. Check your internet connection.';

  @override
  String get errorNoBooks => 'No books found.';

  @override
  String get errorLoadFailed => 'Failed to load books.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get appSlogan2 => 'READ ANYWHERE ANYTIME';

  @override
  String get login => 'Sign In';

  @override
  String get password => 'Password';

  @override
  String get emailEmpty => 'Email cannot be empty';

  @override
  String get enterEmailHint => 'Enter your email';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginError => 'Login failed. Please check your credentials.';

  @override
  String get orEmail => 'or continue with email';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Register Now';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue reading';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get registerLink => 'Register';

  @override
  String get loginLink => 'Sign In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinMessage => 'Join Litera now';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get iAgreeTo => 'I agree to';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get termsDetail =>
      'Please read and agree to our terms before continuing.';

  @override
  String get termsAgreementError => 'You must agree to the terms first.';

  @override
  String get registrationSuccess =>
      'Registration successful! Welcome to Litera.';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join millions of readers';

  @override
  String get registerName => 'Full Name';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerButton => 'Register';

  @override
  String get hasAccount => 'Already have an account? ';

  @override
  String get dashboardTitle => 'Home';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get categoryAll => 'All';

  @override
  String get ratingSection => 'Ratings & Reviews';

  @override
  String get yourRating => 'Rate this Book';

  @override
  String get writeReview => 'Write a review (optional)';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get updateRating => 'Update Rating';

  @override
  String get ratingSuccess => 'Rating saved successfully!';

  @override
  String get ratingError => 'Failed to save rating.';

  @override
  String get noReviews => 'No reviews yet.';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortHighest => 'Highest Rating';

  @override
  String get loginToRate => 'Please login to rate and review this book.';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get chooseLanguageSubtitle =>
      'Select your preferred language for Litera.';

  @override
  String get chooseLanguageConfirm => 'Get Started';

  @override
  String get profilePhotoTitle => 'Choose Profile Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get deletePhoto => 'Remove Photo';

  @override
  String get previewPhoto => 'Photo Preview';

  @override
  String get useThisPhoto => 'Use this photo as your profile picture?';

  @override
  String get photoUpdated => 'Profile photo updated successfully!';

  @override
  String get photoDeleted => 'Profile photo removed.';

  @override
  String get deletePhotoConfirm =>
      'Your profile photo will be removed and replaced with the default avatar.';

  @override
  String get deletePhotoTitle => 'Remove Photo?';

  @override
  String get verificationSent => 'Verification email sent!';

  @override
  String get infoYear => 'Published';

  @override
  String get infoPages => 'Pages';

  @override
  String get infoLanguage => 'Language';

  @override
  String get infoGenre => 'Genre';

  @override
  String get unknownAuthor => 'Unknown Author';

  @override
  String get unknownCategory => 'General';

  @override
  String get noTitle => 'No Title';
}
