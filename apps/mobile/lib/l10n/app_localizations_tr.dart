// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Akıllı Sepet';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get save => 'Kaydet';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get ok => 'Tamam';

  @override
  String get profileTitle => 'Profil';

  @override
  String get nameUpdated => 'Adın güncellendi.';

  @override
  String get profileUpdated => 'Profilin güncellendi.';

  @override
  String get sessionNotFound => 'Oturum bulunamadı. Lütfen tekrar giriş yap.';

  @override
  String get profileLoadFailed => 'Profil yüklenemedi. Lütfen tekrar dene.';

  @override
  String get profileSaveFailed => 'Profil kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get nameSaveFailed => 'Ad kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get countrySaveFailed => 'Ülke kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get photoUploadFailed => 'Fotoğraf yüklenemedi. Lütfen tekrar dene.';

  @override
  String get nameDialogTitle => 'Adın';

  @override
  String get nameDialogHint => 'Adını yaz';

  @override
  String get changePhotoLabel => 'Profil fotoğrafını değiştir';

  @override
  String get addNamePrompt => 'Adını ekle';

  @override
  String get emailNotFound => 'E-posta bulunamadı';

  @override
  String customAllergenConsultPrompt(String value) {
    return '\'$value\' özel bir alerjen. Doğru anlaşıldığından emin olmak için chatbot\'a danışmak ister misin?';
  }

  @override
  String get consultNotNeeded => 'Gerek yok';

  @override
  String get consultAskChatbot => 'Chatbot\'a sor';

  @override
  String customAllergenChatbotPrefill(String value) {
    return 'Profilime alerjen olarak \'$value\' ekledim ama tam emin değilim — bunu netleştirmeme yardım eder misin?';
  }
}
