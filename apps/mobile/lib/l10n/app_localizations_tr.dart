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

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get authWelcome => 'Akıllı Sepet\'e Hoş Geldiniz';

  @override
  String get authTagline => 'Kişiselleştirilmiş alışveriş asistanınız';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get termsLink => 'Kullanım Şartları ve Gizlilik Sözleşmesi';

  @override
  String get termsAcceptSuffix => '\'ni okudum, kabul ediyorum.';

  @override
  String get termsRequiredWarning =>
      'Devam etmek için lütfen Kullanım Şartları ve Gizlilik Sözleşmesi\'ni kabul edin.';

  @override
  String get emailAlreadyRegistered => 'Bu e-posta zaten kayıtlı. Giriş yapın.';

  @override
  String get emailConfirmationNotice =>
      'E-postana bir doğrulama bağlantısı gönderdik. Bağlantıya tıklayıp hesabını doğrulamadan giriş yapamazsın.';

  @override
  String get toggleToSignIn => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get toggleToSignUp => 'Hesabın yok mu? Kayıt ol';

  @override
  String get orSeparator => 'veya';

  @override
  String get googleSignIn => 'Google ile Giriş Yap';

  @override
  String get continueAsGuest => 'Misafir Olarak Devam Et';

  @override
  String get signUpFailed => 'Kayıt başarısız. Lütfen tekrar dene.';

  @override
  String get signInFailed => 'Giriş başarısız. Lütfen tekrar dene.';

  @override
  String get guestSignInFailed =>
      'Misafir girişi başarısız. Lütfen tekrar dene.';

  @override
  String get googleSignInFailed =>
      'Google ile giriş başarısız. Lütfen tekrar dene.';

  @override
  String get termsIntro =>
      'Lütfen Akıllı Sepet uygulamasını kullanmadan önce aşağıdaki kullanım şartlarını ve gizlilik esaslarını dikkatlice okuyunuz.';

  @override
  String get termsSection1Title => '1. Taraflar ve Amaç';

  @override
  String get termsSection1Body =>
      'İşbu sözleşme, Akıllı Sepet uygulaması (\"Uygulama\") ile Uygulamayı kullanan kişi (\"Kullanıcı\") arasında akdedilmiştir. Uygulamanın amacı, kullanıcılara ürün barkodlarını tarama, ürün içeriklerini görüntüleme ve kişisel alerji/diyet tercihlerine göre yapay zeka destekli rehberlik sunmaktır.';

  @override
  String get termsSection2Title =>
      '2. Hizmet Kapsamı ve Sorumluluk Reddi (Önemli Uyarı)';

  @override
  String get termsSection2Body =>
      'Uygulama tarafından sağlanan içerik analizleri, alerjegen uyarıları ve ürün değerlendirmeleri yalnızca bilgilendirme ve rehberlik amaçlıdır. Uygulamadaki veriler resmi ambalaj bilgileri ve açık kaynak veri tabanlarından derlenmektedir. Uygulama hiçbir şekilde tıbbi tavsiye, teşhis veya tedavi niteliği taşımaz. Kullanıcının sağlığı, diyet tercihleri ve ürün tüketimi ile ilgili nihai sorumluluk tamamen Kullanıcıya aittir.';

  @override
  String get termsSection3Title => '3. Kişisel Veriler ve KVKK Aydınlatması';

  @override
  String get termsSection3Body =>
      'Akıllı Sepet, kullanıcının belirlediği alerji, diyet, sağlık verileri ile e-posta adresini hizmetin sunulabilmesi amacıyla güvenli veritabanlarında saklar. Kişisel verileriniz 6698 sayılı KVKK ilkelerine uygun olarak korunmakta olup, üçüncü taraf kurum veya kuruluşlarla ticari amaçla paylaşılmamaktadır.';

  @override
  String get termsSection4Title => '4. Kullanıcı Yükümlülükleri';

  @override
  String get termsSection4Body =>
      'Kullanıcı, kayıt oluştururken doğru ve güncel bilgiler vermeyi, hesap güvenliğini ve şifre gizliliğini korumayı kabul eder. Yetkisiz hesap kullanımı tespiti halinde derhal uygulama yönetimine haber verilmelidir.';

  @override
  String get termsSection5Title => '5. Fesih ve Sözleşme Değişiklikleri';

  @override
  String get termsSection5Body =>
      'Uygulama yönetimi, kullanım şartlarını önceden bildirmeksizin güncelleme hakkını saklı tutar. Güncel şartlar Uygulama içerisinde yayınlandığı tarihte yürürlüğe girer. Kullanıcı dilediği zaman hesabını silerek sözleşmeyi sonlandırabilir.';

  @override
  String get termsLastUpdated => 'Son Güncelleme Tarihi: 11 Ağustos 2026';

  @override
  String get termsClose => 'Anladım ve Kapat';
}
