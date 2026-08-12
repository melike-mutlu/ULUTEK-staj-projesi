import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr')
  ];

  /// Application name shown as the OS task title.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Sepet'**
  String get appTitle;

  /// Settings screen title and profile action tooltip.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// Generic save button label.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// Language selector row label and picker title.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// Language option that follows the device locale.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get languageSystem;

  /// Turkish language option.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// English language option.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get languageEnglish;

  /// Generic cancel button label.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// Generic confirm button label.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// Profile screen app bar title.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// Snackbar shown after the display name is saved.
  ///
  /// In tr, this message translates to:
  /// **'Adın güncellendi.'**
  String get nameUpdated;

  /// Snackbar shown after the profile is saved.
  ///
  /// In tr, this message translates to:
  /// **'Profilin güncellendi.'**
  String get profileUpdated;

  /// Error when the current session cannot be read.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bulunamadı. Lütfen tekrar giriş yap.'**
  String get sessionNotFound;

  /// Error when the profile fails to load.
  ///
  /// In tr, this message translates to:
  /// **'Profil yüklenemedi. Lütfen tekrar dene.'**
  String get profileLoadFailed;

  /// Error when saving the profile fails.
  ///
  /// In tr, this message translates to:
  /// **'Profil kaydedilemedi. Lütfen tekrar dene.'**
  String get profileSaveFailed;

  /// Error when saving the display name fails.
  ///
  /// In tr, this message translates to:
  /// **'Ad kaydedilemedi. Lütfen tekrar dene.'**
  String get nameSaveFailed;

  /// Error when saving the country fails.
  ///
  /// In tr, this message translates to:
  /// **'Ülke kaydedilemedi. Lütfen tekrar dene.'**
  String get countrySaveFailed;

  /// Error when uploading the avatar fails.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf yüklenemedi. Lütfen tekrar dene.'**
  String get photoUploadFailed;

  /// Title of the name edit dialog.
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get nameDialogTitle;

  /// Hint text of the name edit field.
  ///
  /// In tr, this message translates to:
  /// **'Adını yaz'**
  String get nameDialogHint;

  /// Accessibility label and tooltip for the avatar edit action.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafını değiştir'**
  String get changePhotoLabel;

  /// Shown in the header when the user has no display name yet.
  ///
  /// In tr, this message translates to:
  /// **'Adını ekle'**
  String get addNamePrompt;

  /// Header fallback when no email is available.
  ///
  /// In tr, this message translates to:
  /// **'E-posta bulunamadı'**
  String get emailNotFound;

  /// Offers to consult the chatbot about a custom allergen.
  ///
  /// In tr, this message translates to:
  /// **'\'{value}\' özel bir alerjen. Doğru anlaşıldığından emin olmak için chatbot\'a danışmak ister misin?'**
  String customAllergenConsultPrompt(String value);

  /// Declines the chatbot consultation offer.
  ///
  /// In tr, this message translates to:
  /// **'Gerek yok'**
  String get consultNotNeeded;

  /// Accepts the chatbot consultation offer.
  ///
  /// In tr, this message translates to:
  /// **'Chatbot\'a sor'**
  String get consultAskChatbot;

  /// Prefilled chatbot question about a custom allergen.
  ///
  /// In tr, this message translates to:
  /// **'Profilime alerjen olarak \'{value}\' ekledim ama tam emin değilim — bunu netleştirmeme yardım eder misin?'**
  String customAllergenChatbotPrefill(String value);
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
