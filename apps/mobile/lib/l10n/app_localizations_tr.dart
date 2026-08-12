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

  @override
  String get close => 'Kapat';

  @override
  String get understood => 'Anladım';

  @override
  String get update => 'Güncelle';

  @override
  String get settingsSectionAccount => 'HESAP & PROFİL';

  @override
  String get settingsSectionApp => 'UYGULAMA & YASAL';

  @override
  String get settingsSectionSession => 'OTURUM';

  @override
  String get activeSession => 'Aktif Oturum';

  @override
  String get registeredEmail => 'Kayıtlı E-posta';

  @override
  String get editProfileInfo => 'Profil Bilgilerini Düzenle';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get countrySelection => 'Ülke Seçimi';

  @override
  String get notSelected => 'Seçilmedi';

  @override
  String get countryUpdated => 'Ülke seçimi güncellendi.';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get about => 'Hakkında';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get signOutFailed => 'Çıkış yapılamadı. Lütfen tekrar dene.';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get premiumExit => 'Premium\'dan Çık';

  @override
  String get premiumGo => 'Premium\'a Geç';

  @override
  String get premiumActive => 'Aktif';

  @override
  String get premiumTest => 'Test Amaçlı';

  @override
  String get premiumEnabled => 'Premium aktif edildi!';

  @override
  String get premiumDisabled => 'Premium devre dışı bırakıldı.';

  @override
  String get premiumUpdateFailed => 'Premium durumu güncellenemedi.';

  @override
  String get aboutVersion => 'Akıllı Sepet — Versiyon 1.0.0';

  @override
  String get aboutBody1 =>
      'ULUTEK Staj Projesi kapsamında geliştirilmiş, barkod tarama ve yapay zeka destekli akıllı ürün analiz asistanıdır.';

  @override
  String get aboutBody2 =>
      'Kullanıcıların alerji, diyet ve özel sağlık tercihlerine göre ürün içeriklerini otomatik değerlendirir ve kişiselleştirilmiş uyarılarda bulunur.';

  @override
  String get privacyHeading => 'Veri Gizliliği ve Güvenliği';

  @override
  String get privacyBody1 =>
      'Akıllı Sepet uygulaması, seçtiğiniz diyet, alerji ve sağlık verilerini yalnızca size özel ürün analizi yapabilmek amacıyla Supabase veritabanında güvenli bir şekilde saklar.';

  @override
  String get privacyBody2 =>
      'Kişisel verileriniz hiçbir koşulda 3. taraflarla paylaşılmaz. İstediğiniz zaman profilinizden bilgilerinizi güncelleyebilirsiniz.';

  @override
  String get passwordHint =>
      'Yeni şifrenizi girin. Şifreniz en az 6 karakter olmalıdır.';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get newPasswordRepeat => 'Yeni Şifre (Tekrar)';

  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get passwordsDoNotMatch => 'Şifreler birbiriyle eşleşmiyor.';

  @override
  String get passwordUpdated => 'Şifreniz başarıyla güncellendi.';

  @override
  String passwordUpdateFailed(String error) {
    return 'Şifre güncellenemedi: $error';
  }

  @override
  String get deleteAccountConfirmQuestion =>
      'Hesabınızı silmek istediğinize emin misiniz?';

  @override
  String get deleteAccountConfirmBody =>
      'Bu işlem geri alınamaz. Tüm kayıtlı alerji, diyet tercihleriniz ve geçmiş verileriniz kalıcı olarak silinecektir.';

  @override
  String get deleteAccountConfirm => 'Evet, Hesabımı Sil';

  @override
  String get deleteAccountFinalTitle => 'Son kez soruyoruz';

  @override
  String get deleteAccountFinalBody =>
      'Bu son onaydır. Onaylarsan hesabın ve tüm verilerin kalıcı olarak silinecek.';

  @override
  String get deleteAccountFinalConfirm => 'Evet, Eminim — Sil';

  @override
  String get accountDeleted => 'Hesabınız silindi.';

  @override
  String get deleteAccountFailed => 'Hesap silme işlemi gerçekleştirilemedi.';

  @override
  String get statScannedProducts => 'Taranan ürün';

  @override
  String get statAvoidedAllergens => 'Kaçınılan alerjen';

  @override
  String get statMemberDays => 'Üyelik günü';
}
