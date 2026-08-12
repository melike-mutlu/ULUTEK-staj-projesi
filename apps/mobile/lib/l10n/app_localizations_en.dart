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

  @override
  String get close => 'Close';

  @override
  String get understood => 'Got it';

  @override
  String get update => 'Update';

  @override
  String get settingsSectionAccount => 'ACCOUNT & PROFILE';

  @override
  String get settingsSectionApp => 'APP & LEGAL';

  @override
  String get settingsSectionSession => 'SESSION';

  @override
  String get activeSession => 'Active session';

  @override
  String get registeredEmail => 'Registered email';

  @override
  String get editProfileInfo => 'Edit profile information';

  @override
  String get changePassword => 'Change password';

  @override
  String get countrySelection => 'Country';

  @override
  String get notSelected => 'Not selected';

  @override
  String get countryUpdated => 'Country updated.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutFailed => 'Could not sign out. Please try again.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get premiumExit => 'Leave Premium';

  @override
  String get premiumGo => 'Go Premium';

  @override
  String get premiumActive => 'Active';

  @override
  String get premiumTest => 'For testing';

  @override
  String get premiumEnabled => 'Premium enabled!';

  @override
  String get premiumDisabled => 'Premium disabled.';

  @override
  String get premiumUpdateFailed => 'Could not update premium status.';

  @override
  String get aboutVersion => 'Smart Cart — Version 1.0.0';

  @override
  String get aboutBody1 =>
      'Developed as part of the ULUTEK internship project, it is a barcode-scanning, AI-powered smart product analysis assistant.';

  @override
  String get aboutBody2 =>
      'It automatically evaluates product contents against users\' allergy, diet and specific health preferences and provides personalized warnings.';

  @override
  String get privacyHeading => 'Data Privacy and Security';

  @override
  String get privacyBody1 =>
      'Smart Cart stores the diet, allergy and health data you select securely in a Supabase database, solely to provide product analysis tailored to you.';

  @override
  String get privacyBody2 =>
      'Your personal data is never shared with third parties under any circumstances. You can update your information from your profile at any time.';

  @override
  String get passwordHint =>
      'Enter your new password. It must be at least 6 characters.';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordRepeat => 'New password (again)';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get passwordUpdated => 'Your password has been updated.';

  @override
  String passwordUpdateFailed(String error) {
    return 'Could not update password: $error';
  }

  @override
  String get deleteAccountConfirmQuestion =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountConfirmBody =>
      'This action cannot be undone. All your saved allergies, diet preferences and history data will be permanently deleted.';

  @override
  String get deleteAccountConfirm => 'Yes, delete my account';

  @override
  String get deleteAccountFinalTitle => 'One last time';

  @override
  String get deleteAccountFinalBody =>
      'This is the final confirmation. If you confirm, your account and all your data will be permanently deleted.';

  @override
  String get deleteAccountFinalConfirm => 'Yes, I\'m sure — Delete';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get deleteAccountFailed => 'Could not delete the account.';

  @override
  String get statScannedProducts => 'Scanned products';

  @override
  String get statAvoidedAllergens => 'Avoided allergens';

  @override
  String get statMemberDays => 'Member days';
}
