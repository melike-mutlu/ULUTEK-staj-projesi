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

  /// Dark theme toggle row label in Settings.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get darkTheme;

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

  /// Generic close button label.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// Acknowledge button label on informational dialogs.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get understood;

  /// Generic update button label.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// Settings section header for account and profile rows.
  ///
  /// In tr, this message translates to:
  /// **'HESAP & PROFİL'**
  String get settingsSectionAccount;

  /// Settings section header for app and legal rows.
  ///
  /// In tr, this message translates to:
  /// **'UYGULAMA & YASAL'**
  String get settingsSectionApp;

  /// Settings section header for session rows.
  ///
  /// In tr, this message translates to:
  /// **'OTURUM'**
  String get settingsSectionSession;

  /// Subtitle under the user card in settings.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Oturum'**
  String get activeSession;

  /// Settings row label for the registered email.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı E-posta'**
  String get registeredEmail;

  /// Settings row that opens the profile editor.
  ///
  /// In tr, this message translates to:
  /// **'Profil Bilgilerini Düzenle'**
  String get editProfileInfo;

  /// Settings row and dialog title for changing the password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get changePassword;

  /// Settings row label for the country picker.
  ///
  /// In tr, this message translates to:
  /// **'Ülke Seçimi'**
  String get countrySelection;

  /// Subtitle shown when no country is selected.
  ///
  /// In tr, this message translates to:
  /// **'Seçilmedi'**
  String get notSelected;

  /// Snackbar after the country is saved.
  ///
  /// In tr, this message translates to:
  /// **'Ülke seçimi güncellendi.'**
  String get countryUpdated;

  /// Settings row and dialog title for the privacy policy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// Settings row and dialog title for the about section.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// Settings row label to sign out.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// Error snackbar when signing out fails.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılamadı. Lütfen tekrar dene.'**
  String get signOutFailed;

  /// Settings row and dialog title to delete the account.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// Settings row label when premium is active.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'dan Çık'**
  String get premiumExit;

  /// Settings row label when premium is inactive.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Geç'**
  String get premiumGo;

  /// Subtitle when premium is active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get premiumActive;

  /// Subtitle noting premium is for testing.
  ///
  /// In tr, this message translates to:
  /// **'Test Amaçlı'**
  String get premiumTest;

  /// Snackbar when premium is enabled.
  ///
  /// In tr, this message translates to:
  /// **'Premium aktif edildi!'**
  String get premiumEnabled;

  /// Snackbar when premium is disabled.
  ///
  /// In tr, this message translates to:
  /// **'Premium devre dışı bırakıldı.'**
  String get premiumDisabled;

  /// Snackbar when the premium toggle fails.
  ///
  /// In tr, this message translates to:
  /// **'Premium durumu güncellenemedi.'**
  String get premiumUpdateFailed;

  /// App name and version line in the about dialog.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Sepet — Versiyon 1.0.0'**
  String get aboutVersion;

  /// First paragraph of the about dialog.
  ///
  /// In tr, this message translates to:
  /// **'ULUTEK Staj Projesi kapsamında geliştirilmiş, barkod tarama ve yapay zeka destekli akıllı ürün analiz asistanıdır.'**
  String get aboutBody1;

  /// Second paragraph of the about dialog.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıların alerji, diyet ve özel sağlık tercihlerine göre ürün içeriklerini otomatik değerlendirir ve kişiselleştirilmiş uyarılarda bulunur.'**
  String get aboutBody2;

  /// Heading inside the privacy dialog.
  ///
  /// In tr, this message translates to:
  /// **'Veri Gizliliği ve Güvenliği'**
  String get privacyHeading;

  /// First paragraph of the privacy dialog.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Sepet uygulaması, seçtiğiniz diyet, alerji ve sağlık verilerini yalnızca size özel ürün analizi yapabilmek amacıyla Supabase veritabanında güvenli bir şekilde saklar.'**
  String get privacyBody1;

  /// Second paragraph of the privacy dialog.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel verileriniz hiçbir koşulda 3. taraflarla paylaşılmaz. İstediğiniz zaman profilinizden bilgilerinizi güncelleyebilirsiniz.'**
  String get privacyBody2;

  /// Helper text in the change password dialog.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifrenizi girin. Şifreniz en az 6 karakter olmalıdır.'**
  String get passwordHint;

  /// Label for the new password field.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPassword;

  /// Label for the confirm new password field.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre (Tekrar)'**
  String get newPasswordRepeat;

  /// Validation error for a too-short password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get passwordTooShort;

  /// Validation error when passwords differ.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler birbiriyle eşleşmiyor.'**
  String get passwordsDoNotMatch;

  /// Snackbar after the password is updated.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz başarıyla güncellendi.'**
  String get passwordUpdated;

  /// Error when updating the password fails.
  ///
  /// In tr, this message translates to:
  /// **'Şifre güncellenemedi: {error}'**
  String passwordUpdateFailed(String error);

  /// First confirmation question for account deletion.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek istediğinize emin misiniz?'**
  String get deleteAccountConfirmQuestion;

  /// First confirmation body for account deletion.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz. Tüm kayıtlı alerji, diyet tercihleriniz ve geçmiş verileriniz kalıcı olarak silinecektir.'**
  String get deleteAccountConfirmBody;

  /// First confirmation button for account deletion.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Hesabımı Sil'**
  String get deleteAccountConfirm;

  /// Title of the final account deletion confirmation.
  ///
  /// In tr, this message translates to:
  /// **'Son kez soruyoruz'**
  String get deleteAccountFinalTitle;

  /// Body of the final account deletion confirmation.
  ///
  /// In tr, this message translates to:
  /// **'Bu son onaydır. Onaylarsan hesabın ve tüm verilerin kalıcı olarak silinecek.'**
  String get deleteAccountFinalBody;

  /// Final confirmation button for account deletion.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Eminim — Sil'**
  String get deleteAccountFinalConfirm;

  /// Snackbar after the account is deleted.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız silindi.'**
  String get accountDeleted;

  /// Snackbar when account deletion fails.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silme işlemi gerçekleştirilemedi.'**
  String get deleteAccountFailed;

  /// Profile stat tile label for scanned product count.
  ///
  /// In tr, this message translates to:
  /// **'Taranan ürün'**
  String get statScannedProducts;

  /// Profile stat tile label for avoided allergen count.
  ///
  /// In tr, this message translates to:
  /// **'Kaçınılan alerjen'**
  String get statAvoidedAllergens;

  /// Profile stat tile label for days since signup.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik günü'**
  String get statMemberDays;

  /// Sign-up button and title.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signUp;

  /// Sign-in button and title.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// Welcome heading on the auth screen.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Sepet\'e Hoş Geldiniz'**
  String get authWelcome;

  /// Tagline under the welcome heading.
  ///
  /// In tr, this message translates to:
  /// **'Kişiselleştirilmiş alışveriş asistanınız'**
  String get authTagline;

  /// Email field label.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// Password field label.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// Terms and privacy agreement link and dialog title.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları ve Gizlilik Sözleşmesi'**
  String get termsLink;

  /// Text after the terms link in the accept checkbox.
  ///
  /// In tr, this message translates to:
  /// **'\'ni okudum, kabul ediyorum.'**
  String get termsAcceptSuffix;

  /// Warning when the terms are not accepted.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için lütfen Kullanım Şartları ve Gizlilik Sözleşmesi\'ni kabul edin.'**
  String get termsRequiredWarning;

  /// Notice when signing up with an existing email.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı. Giriş yapın.'**
  String get emailAlreadyRegistered;

  /// Notice that email confirmation is required before sign-in.
  ///
  /// In tr, this message translates to:
  /// **'E-postana bir doğrulama bağlantısı gönderdik. Bağlantıya tıklayıp hesabını doğrulamadan giriş yapamazsın.'**
  String get emailConfirmationNotice;

  /// Link switching from sign-up to sign-in.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? Giriş yap'**
  String get toggleToSignIn;

  /// Link switching from sign-in to sign-up.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get toggleToSignUp;

  /// Separator between primary auth and social/guest options.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get orSeparator;

  /// Google sign-in button label.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get googleSignIn;

  /// Guest sign-in button label.
  ///
  /// In tr, this message translates to:
  /// **'Misafir Olarak Devam Et'**
  String get continueAsGuest;

  /// Error when sign-up fails.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız. Lütfen tekrar dene.'**
  String get signUpFailed;

  /// Error when sign-in fails.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız. Lütfen tekrar dene.'**
  String get signInFailed;

  /// Error when guest sign-in fails.
  ///
  /// In tr, this message translates to:
  /// **'Misafir girişi başarısız. Lütfen tekrar dene.'**
  String get guestSignInFailed;

  /// Error when Google sign-in fails.
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş başarısız. Lütfen tekrar dene.'**
  String get googleSignInFailed;

  /// Intro paragraph of the terms dialog.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen Akıllı Sepet uygulamasını kullanmadan önce aşağıdaki kullanım şartlarını ve gizlilik esaslarını dikkatlice okuyunuz.'**
  String get termsIntro;

  /// Terms dialog section 1 title.
  ///
  /// In tr, this message translates to:
  /// **'1. Taraflar ve Amaç'**
  String get termsSection1Title;

  /// Terms dialog section 1 body.
  ///
  /// In tr, this message translates to:
  /// **'İşbu sözleşme, Akıllı Sepet uygulaması (\"Uygulama\") ile Uygulamayı kullanan kişi (\"Kullanıcı\") arasında akdedilmiştir. Uygulamanın amacı, kullanıcılara ürün barkodlarını tarama, ürün içeriklerini görüntüleme ve kişisel alerji/diyet tercihlerine göre yapay zeka destekli rehberlik sunmaktır.'**
  String get termsSection1Body;

  /// Terms dialog section 2 title.
  ///
  /// In tr, this message translates to:
  /// **'2. Hizmet Kapsamı ve Sorumluluk Reddi (Önemli Uyarı)'**
  String get termsSection2Title;

  /// Terms dialog section 2 body.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama tarafından sağlanan içerik analizleri, alerjegen uyarıları ve ürün değerlendirmeleri yalnızca bilgilendirme ve rehberlik amaçlıdır. Uygulamadaki veriler resmi ambalaj bilgileri ve açık kaynak veri tabanlarından derlenmektedir. Uygulama hiçbir şekilde tıbbi tavsiye, teşhis veya tedavi niteliği taşımaz. Kullanıcının sağlığı, diyet tercihleri ve ürün tüketimi ile ilgili nihai sorumluluk tamamen Kullanıcıya aittir.'**
  String get termsSection2Body;

  /// Terms dialog section 3 title.
  ///
  /// In tr, this message translates to:
  /// **'3. Kişisel Veriler ve KVKK Aydınlatması'**
  String get termsSection3Title;

  /// Terms dialog section 3 body.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Sepet, kullanıcının belirlediği alerji, diyet, sağlık verileri ile e-posta adresini hizmetin sunulabilmesi amacıyla güvenli veritabanlarında saklar. Kişisel verileriniz 6698 sayılı KVKK ilkelerine uygun olarak korunmakta olup, üçüncü taraf kurum veya kuruluşlarla ticari amaçla paylaşılmamaktadır.'**
  String get termsSection3Body;

  /// Terms dialog section 4 title.
  ///
  /// In tr, this message translates to:
  /// **'4. Kullanıcı Yükümlülükleri'**
  String get termsSection4Title;

  /// Terms dialog section 4 body.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı, kayıt oluştururken doğru ve güncel bilgiler vermeyi, hesap güvenliğini ve şifre gizliliğini korumayı kabul eder. Yetkisiz hesap kullanımı tespiti halinde derhal uygulama yönetimine haber verilmelidir.'**
  String get termsSection4Body;

  /// Terms dialog section 5 title.
  ///
  /// In tr, this message translates to:
  /// **'5. Fesih ve Sözleşme Değişiklikleri'**
  String get termsSection5Title;

  /// Terms dialog section 5 body.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama yönetimi, kullanım şartlarını önceden bildirmeksizin güncelleme hakkını saklı tutar. Güncel şartlar Uygulama içerisinde yayınlandığı tarihte yürürlüğe girer. Kullanıcı dilediği zaman hesabını silerek sözleşmeyi sonlandırabilir.'**
  String get termsSection5Body;

  /// Last-updated line in the terms dialog.
  ///
  /// In tr, this message translates to:
  /// **'Son Güncelleme Tarihi: 11 Ağustos 2026'**
  String get termsLastUpdated;

  /// Close button of the terms dialog.
  ///
  /// In tr, this message translates to:
  /// **'Anladım ve Kapat'**
  String get termsClose;

  /// Greeting above the user name on the home screen.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba,'**
  String get homeGreeting;

  /// Fallback name when the user has no display name.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get userFallback;

  /// Label on the large scan button.
  ///
  /// In tr, this message translates to:
  /// **'Tara'**
  String get scanButton;

  /// Tagline under the scan button.
  ///
  /// In tr, this message translates to:
  /// **'Bir ürünün barkodunu okut, içeriğini ve\nsana uygunluğunu öğren'**
  String get scanTagline;

  /// Heading for the recent scans list.
  ///
  /// In tr, this message translates to:
  /// **'Son Taramaların'**
  String get recentScansTitle;

  /// Empty state when there are no scans.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir ürün taramadınız.'**
  String get noScansYet;

  /// Note badge on a recent scan card.
  ///
  /// In tr, this message translates to:
  /// **'İçerik Analizi'**
  String get contentAnalysis;

  /// Fallback title showing the barcode when the product name is unknown.
  ///
  /// In tr, this message translates to:
  /// **'Barkod: {barcode}'**
  String barcodeLabel(String barcode);

  /// Button opening the full scan history sheet.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Geçmişi Gör'**
  String get seeAllHistory;

  /// Title of the full scan history sheet.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Taramalarım'**
  String get allMyScans;

  /// Empty state in the full history sheet.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş bulunamadı.'**
  String get historyNotFound;

  /// Empty state for product search.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı.'**
  String get searchNoResults;

  /// Error state for product search.
  ///
  /// In tr, this message translates to:
  /// **'Arama sırasında bir hata oluştu. Lütfen tekrar deneyin.'**
  String get searchError;

  /// Title of the ad placeholder card.
  ///
  /// In tr, this message translates to:
  /// **'REKLAM ALANI'**
  String get adArea;

  /// Sponsored tag on the ad placeholder card.
  ///
  /// In tr, this message translates to:
  /// **'Sponsorlu'**
  String get sponsored;

  /// Body of the ad placeholder card.
  ///
  /// In tr, this message translates to:
  /// **'Burada sponsorlu ürün duyuruları veya dinamik reklamlar görüntülenecektir.'**
  String get adPlaceholderBody;

  /// Note about removing ads via Premium.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar\'dan Premium\'a geçerek reklamları kaldırabilirsiniz.'**
  String get adRemovePremiumNote;

  /// Scan screen app bar title.
  ///
  /// In tr, this message translates to:
  /// **'Barkod Tara'**
  String get scanTitle;

  /// Hint under the scanner frame.
  ///
  /// In tr, this message translates to:
  /// **'Barkodu çerçeve içine hizala,\notomatik olarak okunacak'**
  String get scanFrameHint;

  /// Button to enter a barcode manually.
  ///
  /// In tr, this message translates to:
  /// **'Barkodu Elle Gir'**
  String get enterBarcodeManually;

  /// Manual barcode dialog title.
  ///
  /// In tr, this message translates to:
  /// **'Barkodu Girin'**
  String get enterBarcode;

  /// Example hint in the manual barcode field.
  ///
  /// In tr, this message translates to:
  /// **'Örn: 8690504112233'**
  String get barcodeHintExample;

  /// Search button in the manual barcode dialog.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get searchAction;

  /// Chatbot screen title.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Asistan'**
  String get chatbotTitle;

  /// Chatbot greeting with the user name.
  ///
  /// In tr, this message translates to:
  /// **'Size nasıl yardımcı olabilirim {name}?'**
  String chatbotGreeting(String name);

  /// Header of an AI suggestion card.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka Önerisi'**
  String get aiSuggestion;

  /// Fallback text for a suggestion card with no message.
  ///
  /// In tr, this message translates to:
  /// **'Profilinize yeni bir özellik eklememi ister misiniz?'**
  String get suggestionFallback;

  /// Decline button on a suggestion card.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// Accept button on a suggestion card.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Ekle'**
  String get yesAdd;

  /// Indicator shown while the assistant is composing a reply.
  ///
  /// In tr, this message translates to:
  /// **'Asistan yazıyor...'**
  String get assistantTyping;

  /// Chat input placeholder.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler sorun...'**
  String get askSomething;

  /// Button to start a new chat.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Sohbet Başlat'**
  String get newChat;

  /// Paywall heading on the chatbot screen.
  ///
  /// In tr, this message translates to:
  /// **'Premium Özellik'**
  String get premiumFeature;

  /// Paywall body on the chatbot screen.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet asistanını kullanmak ve profilinize özel yapay zeka tavsiyeleri almak için Premium üye olmanız gerekmektedir.'**
  String get chatbotPaywallBody;

  /// Paywall action button to open settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlara Git'**
  String get goToSettings;

  /// Bot message shown when a chat request fails.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu. Lütfen tekrar dene.'**
  String get chatError;

  /// Suffix appended to a handled suggestion message.
  ///
  /// In tr, this message translates to:
  /// **'Profilinize eklendi'**
  String get addedToProfile;

  /// Snackbar after a suggested value is added to the profile.
  ///
  /// In tr, this message translates to:
  /// **'{value} profilinize eklendi!'**
  String addedToProfileSnack(String value);

  /// App bar title of the report-product screen.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Bulunamadı — Bildir'**
  String get reportProductTitle;

  /// Success dialog title after reporting a product.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Alındı'**
  String get reportReceivedTitle;

  /// Success dialog body after reporting a product.
  ///
  /// In tr, this message translates to:
  /// **'Ürün bildirimi ve fotoğraflarınız başarıyla sisteme kaydedildi. Katkınız için teşekkür ederiz!'**
  String get reportReceivedBody;

  /// Info header on the report-product screen.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürünü veritabanımıza eklememize yardımcı olun. Fotoğrafları yükleyerek doğruluk oranını artırabilirsiniz.'**
  String get reportIntro;

  /// Section header for product information fields.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Bilgileri'**
  String get productInfo;

  /// Barcode field label on the report-product form.
  ///
  /// In tr, this message translates to:
  /// **'Barkod No *'**
  String get barcodeNumberLabel;

  /// Product name/brand field label.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Adı & Markası'**
  String get productNameBrandLabel;

  /// Example hint for the product name field.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Ülker Çikolatalı Gofret'**
  String get productNameHintExample;

  /// Ingredients text field label.
  ///
  /// In tr, this message translates to:
  /// **'İçindekiler Metni (İsteğe Bağlı)'**
  String get ingredientsTextOptionalLabel;

  /// Hint explaining AI autofill of the ingredients field.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çektiğinizde yapay zeka burayı otomatik doldurur. Gerekirse elle düzeltebilirsiniz.'**
  String get ingredientsAutofillHint;

  /// Section header for product photos.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Fotoğrafları'**
  String get productPhotos;

  /// Instruction under the product photos header.
  ///
  /// In tr, this message translates to:
  /// **'Ürünün ön yüzü, içindekiler kısmı ve besin değerleri tablosunu çekin veya seçin.'**
  String get productPhotosNote;

  /// Label for the front photo card.
  ///
  /// In tr, this message translates to:
  /// **'Ön Yüz'**
  String get photoFront;

  /// Label for the ingredients photo card.
  ///
  /// In tr, this message translates to:
  /// **'İçindekiler'**
  String get photoIngredients;

  /// Label for the nutrition photo card.
  ///
  /// In tr, this message translates to:
  /// **'Besin Değeri'**
  String get photoNutrition;

  /// Submit button label while submitting.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor...'**
  String get submitting;

  /// Submit button label on the report-product form.
  ///
  /// In tr, this message translates to:
  /// **'Ürünü Bildir'**
  String get reportProduct;

  /// Photo source option: camera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera ile Çek'**
  String get takePhoto;

  /// Photo source option: gallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get pickFromGallery;

  /// Validation error for an empty/invalid barcode.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir barkod giriniz.'**
  String get invalidBarcode;

  /// Error when submitting a pending product fails.
  ///
  /// In tr, this message translates to:
  /// **'Gönderim başarısız oldu.'**
  String get submitFailed;

  /// Product detail app bar title.
  ///
  /// In tr, this message translates to:
  /// **'Ürün Detayı'**
  String get productDetailTitle;

  /// Loading state on the product detail screen.
  ///
  /// In tr, this message translates to:
  /// **'Ürün bilgileri ve AI analizi getiriliyor...'**
  String get loadingProductAnalysis;

  /// Section title for diet preference checks.
  ///
  /// In tr, this message translates to:
  /// **'Diyet türü'**
  String get dietType;

  /// Empty state for the diet section.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı bir diyet tercihin yok.'**
  String get noDietPreference;

  /// Section title for health condition checks.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık durumu'**
  String get healthConditionTitle;

  /// Empty state for the health section.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı bir sağlık durumun yok.'**
  String get noHealthCondition;

  /// Button to report a product.
  ///
  /// In tr, this message translates to:
  /// **'Ürünü Bize Bildir'**
  String get reportToUs;

  /// Error state title on product detail.
  ///
  /// In tr, this message translates to:
  /// **'Bir Hata Oluştu'**
  String get errorOccurred;

  /// Error state body on product detail.
  ///
  /// In tr, this message translates to:
  /// **'Ürün detayları yüklenirken sunucu ile iletişim kurulamadı.'**
  String get productDetailServerError;

  /// Go back button.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön'**
  String get goBack;

  /// Retry button.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// Not-found state title.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürünü veritabanımızda\nbulamadık'**
  String get productNotFoundTitle;

  /// Not-found state body.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış bilgi vermektense dürüst olmayı tercih ederiz. Barkodu elle girebilir ya da ürünü bize bildirerek yardımcı olabilirsin.'**
  String get productNotFoundBody;

  /// Demo button showing a sample product.
  ///
  /// In tr, this message translates to:
  /// **'Örnek Ürünü Göster (Demo)'**
  String get sampleProductDemo;

  /// Personal allergens section title.
  ///
  /// In tr, this message translates to:
  /// **'Alerjiler'**
  String get allergiesTitle;

  /// Shown when allergen data is missing.
  ///
  /// In tr, this message translates to:
  /// **'İçerik bilgisi eksik, alerjen kontrolü yapılamadı.'**
  String get insufficientAllergenInfo;

  /// Meta count of allergen warnings.
  ///
  /// In tr, this message translates to:
  /// **'{count} uyarı'**
  String warningsCount(int count);

  /// No personal allergens in the product.
  ///
  /// In tr, this message translates to:
  /// **'Profilindeki alerjenlerin hiçbiri bu üründe yok.'**
  String get noProfileAllergens;

  /// Row subtitle for a conflicting allergen.
  ///
  /// In tr, this message translates to:
  /// **'Profilindeki alerjilerle çakışıyor'**
  String get conflictsWithAllergies;

  /// Section title for non-personal allergens.
  ///
  /// In tr, this message translates to:
  /// **'Diğer alerjenler'**
  String get otherAllergensTitle;

  /// Meta for other allergens.
  ///
  /// In tr, this message translates to:
  /// **'profilinde yok'**
  String get notInYourProfile;

  /// Ingredients section title.
  ///
  /// In tr, this message translates to:
  /// **'İçindekiler'**
  String get ingredientsTitle;

  /// Empty state for ingredients.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün için içindekiler bilgisi yok.'**
  String get noIngredientsInfo;

  /// Collapse a long text.
  ///
  /// In tr, this message translates to:
  /// **'Daha az göster'**
  String get showLess;

  /// Expand a long text.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü göster'**
  String get showAllText;

  /// Nutrition facts section title.
  ///
  /// In tr, this message translates to:
  /// **'Besin değerleri'**
  String get nutrimentsTitle;

  /// Meta noting values are per 100 g.
  ///
  /// In tr, this message translates to:
  /// **'100 g için'**
  String get per100g;

  /// Shown when a nutrient value is missing.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi yok'**
  String get noInfo;

  /// Badge for an unverified product.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulanmadı'**
  String get unverified;

  /// Reason shown when content data is insufficient.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürünün içerik bilgisi eksik.'**
  String get insufficientContentInfo;

  /// Recommendations section title.
  ///
  /// In tr, this message translates to:
  /// **'Öneriler'**
  String get recommendationsTitle;

  /// See-all link for recommendations.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör'**
  String get seeAll;

  /// Neutrality note under recommendations.
  ///
  /// In tr, this message translates to:
  /// **'Seçimlerimiz tarafsızdır: hiçbir marka burada yer almak için ödeme yapmaz.'**
  String get recommendationsNeutralityNote;

  /// Energy nutrient label.
  ///
  /// In tr, this message translates to:
  /// **'Enerji'**
  String get nutrientEnergy;

  /// Sugar nutrient label.
  ///
  /// In tr, this message translates to:
  /// **'Şeker'**
  String get nutrientSugar;

  /// Fat nutrient label.
  ///
  /// In tr, this message translates to:
  /// **'Yağ'**
  String get nutrientFat;

  /// Protein nutrient label.
  ///
  /// In tr, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// Low energy note.
  ///
  /// In tr, this message translates to:
  /// **'Düşük kalorili'**
  String get energyLow;

  /// Medium energy note.
  ///
  /// In tr, this message translates to:
  /// **'Orta kalorili'**
  String get energyMedium;

  /// High energy note.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek kalorili'**
  String get energyHigh;

  /// Low sugar note.
  ///
  /// In tr, this message translates to:
  /// **'Az şekerli'**
  String get sugarLow;

  /// Medium sugar note.
  ///
  /// In tr, this message translates to:
  /// **'Orta düzeyde şekerli'**
  String get sugarMedium;

  /// High sugar note.
  ///
  /// In tr, this message translates to:
  /// **'Çok şekerli'**
  String get sugarHigh;

  /// Low fat note.
  ///
  /// In tr, this message translates to:
  /// **'Az yağlı'**
  String get fatLow;

  /// Medium fat note.
  ///
  /// In tr, this message translates to:
  /// **'Orta düzeyde yağlı'**
  String get fatMedium;

  /// High fat note.
  ///
  /// In tr, this message translates to:
  /// **'Çok yağlı'**
  String get fatHigh;

  /// High protein note.
  ///
  /// In tr, this message translates to:
  /// **'Protein açısından zengin'**
  String get proteinHigh;

  /// Medium protein note.
  ///
  /// In tr, this message translates to:
  /// **'Bir miktar protein'**
  String get proteinMedium;

  /// Low protein note.
  ///
  /// In tr, this message translates to:
  /// **'Çok az protein'**
  String get proteinLow;

  /// Profile check note when it can't be judged.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün için değerlendirilemedi'**
  String get checkNotEvaluated;

  /// Diet check note when incompatible.
  ///
  /// In tr, this message translates to:
  /// **'Bu üründe uygun olmayan içerik var'**
  String get dietIncompatibleNote;

  /// Diet check note when compatible.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün tercihinle uyumlu'**
  String get dietCompatibleNote;

  /// Health check note when risky.
  ///
  /// In tr, this message translates to:
  /// **'Bu üründe durumun için riskli içerik var'**
  String get healthConflictNote;

  /// Health check note when fine.
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün için özel bir uyarı yok'**
  String get healthOkNote;

  /// Prefix of the flat allergen warning; the allergen names follow.
  ///
  /// In tr, this message translates to:
  /// **'Sende alerji yapan '**
  String get reasonAllergenIntro;

  /// Suffix of the flat allergen warning.
  ///
  /// In tr, this message translates to:
  /// **' içeriyor. '**
  String get reasonAllergenOutro;

  /// Connector between the last two items in a list.
  ///
  /// In tr, this message translates to:
  /// **' ve '**
  String get reasonAnd;

  /// Suffix after a diet label in the flat warning.
  ///
  /// In tr, this message translates to:
  /// **' beslenmene uygun değil. '**
  String get reasonDietOutro;

  /// Prefix before a health label in the flat warning.
  ///
  /// In tr, this message translates to:
  /// **'Profilindeki '**
  String get reasonHealthIntro;

  /// Connector between a health label and its note.
  ///
  /// In tr, this message translates to:
  /// **' için: '**
  String get reasonHealthMid;

  /// Prefix of the allergen bullet line (empty in Turkish).
  ///
  /// In tr, this message translates to:
  /// **''**
  String get reasonAllergenLineIntro;

  /// Suffix of the allergen bullet line.
  ///
  /// In tr, this message translates to:
  /// **' içeriyor.'**
  String get reasonAllergenLineOutro;

  /// Suffix of the diet bullet line.
  ///
  /// In tr, this message translates to:
  /// **' beslenmene uygun değil.'**
  String get reasonDietLineOutro;

  /// Suffix of the health bullet line.
  ///
  /// In tr, this message translates to:
  /// **' durumu için uygun değil.'**
  String get reasonHealthLineOutro;

  /// Verdict when the product is suitable.
  ///
  /// In tr, this message translates to:
  /// **'Uygun'**
  String get verdictSuitable;

  /// Verdict when caution is advised.
  ///
  /// In tr, this message translates to:
  /// **'Dikkatli ol'**
  String get verdictCaution;

  /// Verdict when the product is unsuitable.
  ///
  /// In tr, this message translates to:
  /// **'Uygun değil!'**
  String get verdictUnsuitable;

  /// Verdict when there is not enough data.
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz veri'**
  String get verdictInsufficient;

  /// Fallback allergen label.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen alerjen'**
  String get allergenUnknown;

  /// Allergen: gluten.
  ///
  /// In tr, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// Allergen: milk/lactose.
  ///
  /// In tr, this message translates to:
  /// **'Süt / Laktoz'**
  String get allergenMilk;

  /// Allergen: eggs.
  ///
  /// In tr, this message translates to:
  /// **'Yumurta'**
  String get allergenEggs;

  /// Allergen: soy.
  ///
  /// In tr, this message translates to:
  /// **'Soya'**
  String get allergenSoy;

  /// Allergen: peanuts.
  ///
  /// In tr, this message translates to:
  /// **'Yer fıstığı'**
  String get allergenPeanuts;

  /// Allergen: tree nuts.
  ///
  /// In tr, this message translates to:
  /// **'Kabuklu yemişler'**
  String get allergenNuts;

  /// Allergen: sesame.
  ///
  /// In tr, this message translates to:
  /// **'Susam'**
  String get allergenSesame;

  /// Allergen: fish.
  ///
  /// In tr, this message translates to:
  /// **'Balık'**
  String get allergenFish;

  /// Allergen: crustaceans.
  ///
  /// In tr, this message translates to:
  /// **'Kabuklu deniz ürünleri'**
  String get allergenCrustaceans;

  /// Allergen: molluscs.
  ///
  /// In tr, this message translates to:
  /// **'Yumuşakçalar'**
  String get allergenMolluscs;

  /// Allergen: celery.
  ///
  /// In tr, this message translates to:
  /// **'Kereviz'**
  String get allergenCelery;

  /// Allergen: mustard.
  ///
  /// In tr, this message translates to:
  /// **'Hardal'**
  String get allergenMustard;

  /// Allergen: lupin.
  ///
  /// In tr, this message translates to:
  /// **'Acı bakla'**
  String get allergenLupin;

  /// Allergen: sulphites.
  ///
  /// In tr, this message translates to:
  /// **'Sülfitler'**
  String get allergenSulphites;

  /// Bottom navigation label for the home tab.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// Bottom navigation label for the chatbot tab.
  ///
  /// In tr, this message translates to:
  /// **'Chatbot'**
  String get navChatbot;

  /// Hint text for the product search field.
  ///
  /// In tr, this message translates to:
  /// **'Ürün ara'**
  String get searchProductHint;

  /// Title of the dialog to add a custom chip option.
  ///
  /// In tr, this message translates to:
  /// **'Seçenek ekle'**
  String get addOption;

  /// Confirm button that adds a custom option.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get addAction;

  /// Title of the country selection dialog.
  ///
  /// In tr, this message translates to:
  /// **'Ülke Seçimi'**
  String get countryDialogTitle;

  /// Hint for the country name text field.
  ///
  /// In tr, this message translates to:
  /// **'Ülke adı yazınız (örn. Türkiye)'**
  String get countryDialogHint;

  /// Label above the quick-pick country chips.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Seçim'**
  String get quickSelect;

  /// Error shown on the startup gate when the profile cannot be loaded.
  ///
  /// In tr, this message translates to:
  /// **'Profilin yüklenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get profileLoadRetry;

  /// Relative time for a moment ago.
  ///
  /// In tr, this message translates to:
  /// **'az önce'**
  String get relativeJustNow;

  /// Relative time in minutes.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk önce'**
  String relativeMinutesAgo(int count);

  /// Relative time in hours.
  ///
  /// In tr, this message translates to:
  /// **'{count} saat önce'**
  String relativeHoursAgo(int count);

  /// Relative time for the previous day.
  ///
  /// In tr, this message translates to:
  /// **'dün'**
  String get relativeYesterday;

  /// Relative time in days.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String relativeDaysAgo(int count);
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
