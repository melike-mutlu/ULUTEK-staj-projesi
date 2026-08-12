// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Cart';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get profileTitle => 'Profile';

  @override
  String get nameUpdated => 'Your name has been updated.';

  @override
  String get profileUpdated => 'Your profile has been updated.';

  @override
  String get sessionNotFound => 'Session not found. Please sign in again.';

  @override
  String get profileLoadFailed =>
      'Could not load your profile. Please try again.';

  @override
  String get profileSaveFailed =>
      'Could not save your profile. Please try again.';

  @override
  String get nameSaveFailed => 'Could not save your name. Please try again.';

  @override
  String get countrySaveFailed =>
      'Could not save your country. Please try again.';

  @override
  String get photoUploadFailed =>
      'Could not upload the photo. Please try again.';

  @override
  String get nameDialogTitle => 'Your name';

  @override
  String get nameDialogHint => 'Enter your name';

  @override
  String get changePhotoLabel => 'Change profile photo';

  @override
  String get addNamePrompt => 'Add your name';

  @override
  String get emailNotFound => 'Email not found';

  @override
  String customAllergenConsultPrompt(String value) {
    return '\'$value\' is a custom allergen. Would you like to consult the chatbot to make sure it\'s understood correctly?';
  }

  @override
  String get consultNotNeeded => 'No need';

  @override
  String get consultAskChatbot => 'Ask the chatbot';

  @override
  String customAllergenChatbotPrefill(String value) {
    return 'I added \'$value\' as an allergen to my profile but I\'m not entirely sure — could you help me clarify it?';
  }
}
