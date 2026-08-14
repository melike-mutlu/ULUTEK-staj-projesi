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
  String get darkTheme => 'Koyu Tema';

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

  @override
  String get homeGreeting => 'Merhaba,';

  @override
  String get userFallback => 'Kullanıcı';

  @override
  String get scanButton => 'Tara';

  @override
  String get scanTagline =>
      'Bir ürünün barkodunu okut, içeriğini ve\nsana uygunluğunu öğren';

  @override
  String get recentScansTitle => 'Son Taramaların';

  @override
  String get noScansYet => 'Henüz bir ürün taramadınız.';

  @override
  String get contentAnalysis => 'İçerik Analizi';

  @override
  String barcodeLabel(String barcode) {
    return 'Barkod: $barcode';
  }

  @override
  String get seeAllHistory => 'Tüm Geçmişi Gör';

  @override
  String get allMyScans => 'Tüm Taramalarım';

  @override
  String get historyNotFound => 'Geçmiş bulunamadı.';

  @override
  String get searchNoResults => 'Sonuç bulunamadı.';

  @override
  String get searchError =>
      'Arama sırasında bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get adArea => 'REKLAM ALANI';

  @override
  String get sponsored => 'Sponsorlu';

  @override
  String get adPlaceholderBody =>
      'Burada sponsorlu ürün duyuruları veya dinamik reklamlar görüntülenecektir.';

  @override
  String get adRemovePremiumNote =>
      'Ayarlar\'dan Premium\'a geçerek reklamları kaldırabilirsiniz.';

  @override
  String get scanTitle => 'Barkod Tara';

  @override
  String get scanFrameHint =>
      'Barkodu çerçeve içine hizala,\notomatik olarak okunacak';

  @override
  String get enterBarcodeManually => 'Barkodu Elle Gir';

  @override
  String get enterBarcode => 'Barkodu Girin';

  @override
  String get barcodeHintExample => 'Örn: 8690504112233';

  @override
  String get searchAction => 'Ara';

  @override
  String get chatbotTitle => 'Akıllı Asistan';

  @override
  String chatbotGreeting(String name) {
    return 'Size nasıl yardımcı olabilirim $name?';
  }

  @override
  String get aiSuggestion => 'Yapay Zeka Önerisi';

  @override
  String get suggestionFallback =>
      'Profilinize yeni bir özellik eklememi ister misiniz?';

  @override
  String get no => 'Hayır';

  @override
  String get yesAdd => 'Evet, Ekle';

  @override
  String get assistantTyping => 'Asistan yazıyor...';

  @override
  String get askSomething => 'Bir şeyler sorun...';

  @override
  String get newChat => 'Yeni Sohbet Başlat';

  @override
  String get premiumFeature => 'Premium Özellik';

  @override
  String get chatbotPaywallBody =>
      'Sohbet asistanını kullanmak ve profilinize özel yapay zeka tavsiyeleri almak için Premium üye olmanız gerekmektedir.';

  @override
  String get goToSettings => 'Ayarlara Git';

  @override
  String get chatError => 'Bir hata oluştu. Lütfen tekrar dene.';

  @override
  String get addedToProfile => 'Profilinize eklendi';

  @override
  String addedToProfileSnack(String value) {
    return '$value profilinize eklendi!';
  }

  @override
  String get reportProductTitle => 'Ürün Bulunamadı — Bildir';

  @override
  String get reportReceivedTitle => 'Bildirim Alındı';

  @override
  String get reportReceivedBody =>
      'Ürün bildirimi ve fotoğraflarınız başarıyla sisteme kaydedildi. Katkınız için teşekkür ederiz!';

  @override
  String get reportIntro =>
      'Bu ürünü veritabanımıza eklememize yardımcı olun. Fotoğrafları yükleyerek doğruluk oranını artırabilirsiniz.';

  @override
  String get productInfo => 'Ürün Bilgileri';

  @override
  String get barcodeNumberLabel => 'Barkod No *';

  @override
  String get productNameBrandLabel => 'Ürün Adı & Markası';

  @override
  String get productNameHintExample => 'Örn: Ülker Çikolatalı Gofret';

  @override
  String get ingredientsTextOptionalLabel => 'İçindekiler Metni (İsteğe Bağlı)';

  @override
  String get ingredientsAutofillHint =>
      'Fotoğraf çektiğinizde yapay zeka burayı otomatik doldurur. Gerekirse elle düzeltebilirsiniz.';

  @override
  String get productPhotos => 'Ürün Fotoğrafları';

  @override
  String get productPhotosNote =>
      'Ürünün ön yüzü, içindekiler kısmı ve besin değerleri tablosunu çekin veya seçin.';

  @override
  String get photoFront => 'Ön Yüz';

  @override
  String get photoIngredients => 'İçindekiler';

  @override
  String get photoNutrition => 'Besin Değeri';

  @override
  String get submitting => 'Gönderiliyor...';

  @override
  String get reportProduct => 'Ürünü Bildir';

  @override
  String get takePhoto => 'Kamera ile Çek';

  @override
  String get pickFromGallery => 'Galeriden Seç';

  @override
  String get invalidBarcode => 'Lütfen geçerli bir barkod giriniz.';

  @override
  String get submitFailed => 'Gönderim başarısız oldu.';

  @override
  String get productDetailTitle => 'Ürün Detayı';

  @override
  String get loadingProductAnalysis =>
      'Ürün bilgileri ve AI analizi getiriliyor...';

  @override
  String get dietType => 'Diyet türü';

  @override
  String get noDietPreference => 'Kayıtlı bir diyet tercihin yok.';

  @override
  String get healthConditionTitle => 'Sağlık durumu';

  @override
  String get noHealthCondition => 'Kayıtlı bir sağlık durumun yok.';

  @override
  String get reportToUs => 'Ürünü Bize Bildir';

  @override
  String get errorOccurred => 'Bir Hata Oluştu';

  @override
  String get productDetailServerError =>
      'Ürün detayları yüklenirken sunucu ile iletişim kurulamadı.';

  @override
  String get goBack => 'Geri Dön';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get productNotFoundTitle => 'Bu ürünü veritabanımızda\nbulamadık';

  @override
  String get productNotFoundBody =>
      'Yanlış bilgi vermektense dürüst olmayı tercih ederiz. Barkodu elle girebilir ya da ürünü bize bildirerek yardımcı olabilirsin.';

  @override
  String get sampleProductDemo => 'Örnek Ürünü Göster (Demo)';

  @override
  String get allergiesTitle => 'Alerjiler';

  @override
  String get insufficientAllergenInfo =>
      'İçerik bilgisi eksik, alerjen kontrolü yapılamadı.';

  @override
  String warningsCount(int count) {
    return '$count uyarı';
  }

  @override
  String get noProfileAllergens =>
      'Profilindeki alerjenlerin hiçbiri bu üründe yok.';

  @override
  String get conflictsWithAllergies => 'Profilindeki alerjilerle çakışıyor';

  @override
  String get otherAllergensTitle => 'Diğer alerjenler';

  @override
  String get notInYourProfile => 'profilinde yok';

  @override
  String get ingredientsTitle => 'İçindekiler';

  @override
  String get noIngredientsInfo => 'Bu ürün için içindekiler bilgisi yok.';

  @override
  String get showLess => 'Daha az göster';

  @override
  String get showAllText => 'Tümünü göster';

  @override
  String get nutrimentsTitle => 'Besin değerleri';

  @override
  String get per100g => '100 g için';

  @override
  String get noInfo => 'Bilgi yok';

  @override
  String get unverified => 'Doğrulanmadı';

  @override
  String get insufficientContentInfo => 'Bu ürünün içerik bilgisi eksik.';

  @override
  String get recommendationsTitle => 'Öneriler';

  @override
  String get seeAll => 'Tümünü gör';

  @override
  String get recommendationsNeutralityNote =>
      'Seçimlerimiz tarafsızdır: hiçbir marka burada yer almak için ödeme yapmaz.';

  @override
  String get nutrientEnergy => 'Enerji';

  @override
  String get nutrientSugar => 'Şeker';

  @override
  String get nutrientFat => 'Yağ';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get energyLow => 'Düşük kalorili';

  @override
  String get energyMedium => 'Orta kalorili';

  @override
  String get energyHigh => 'Yüksek kalorili';

  @override
  String get sugarLow => 'Az şekerli';

  @override
  String get sugarMedium => 'Orta düzeyde şekerli';

  @override
  String get sugarHigh => 'Çok şekerli';

  @override
  String get fatLow => 'Az yağlı';

  @override
  String get fatMedium => 'Orta düzeyde yağlı';

  @override
  String get fatHigh => 'Çok yağlı';

  @override
  String get proteinHigh => 'Protein açısından zengin';

  @override
  String get proteinMedium => 'Bir miktar protein';

  @override
  String get proteinLow => 'Çok az protein';

  @override
  String get checkNotEvaluated => 'Bu ürün için değerlendirilemedi';

  @override
  String get dietIncompatibleNote => 'Bu üründe uygun olmayan içerik var';

  @override
  String get dietCompatibleNote => 'Bu ürün tercihinle uyumlu';

  @override
  String get healthConflictNote => 'Bu üründe durumun için riskli içerik var';

  @override
  String get healthOkNote => 'Bu ürün için özel bir uyarı yok';

  @override
  String get reasonAllergenIntro => 'Sende alerji yapan ';

  @override
  String get reasonAllergenOutro => ' içeriyor. ';

  @override
  String get reasonAnd => ' ve ';

  @override
  String get reasonDietOutro => ' beslenmene uygun değil. ';

  @override
  String get reasonHealthIntro => 'Profilindeki ';

  @override
  String get reasonHealthMid => ' için: ';

  @override
  String get reasonAllergenLineIntro => '';

  @override
  String get reasonAllergenLineOutro => ' içeriyor.';

  @override
  String get reasonDietLineOutro => ' beslenmene uygun değil.';

  @override
  String get reasonHealthLineOutro => ' durumu için uygun değil.';

  @override
  String get verdictSuitable => 'Uygun';

  @override
  String get verdictCaution => 'Dikkatli ol';

  @override
  String get verdictUnsuitable => 'Uygun değil!';

  @override
  String get verdictInsufficient => 'Yetersiz veri';

  @override
  String get allergenUnknown => 'Bilinmeyen alerjen';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenMilk => 'Süt / Laktoz';

  @override
  String get allergenEggs => 'Yumurta';

  @override
  String get allergenSoy => 'Soya';

  @override
  String get allergenPeanuts => 'Yer fıstığı';

  @override
  String get allergenNuts => 'Kabuklu yemişler';

  @override
  String get allergenSesame => 'Susam';

  @override
  String get allergenFish => 'Balık';

  @override
  String get allergenCrustaceans => 'Kabuklu deniz ürünleri';

  @override
  String get allergenMolluscs => 'Yumuşakçalar';

  @override
  String get allergenCelery => 'Kereviz';

  @override
  String get allergenMustard => 'Hardal';

  @override
  String get allergenLupin => 'Acı bakla';

  @override
  String get allergenSulphites => 'Sülfitler';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navChatbot => 'Chatbot';

  @override
  String get searchProductHint => 'Ürün ara';

  @override
  String get addOption => 'Seçenek ekle';

  @override
  String get addAction => 'Ekle';

  @override
  String get countryDialogTitle => 'Ülke Seçimi';

  @override
  String get countryDialogHint => 'Ülke adı yazınız (örn. Türkiye)';

  @override
  String get quickSelect => 'Hızlı Seçim';

  @override
  String get profileLoadRetry =>
      'Profilin yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get relativeJustNow => 'az önce';

  @override
  String relativeMinutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String relativeHoursAgo(int count) {
    return '$count saat önce';
  }

  @override
  String get relativeYesterday => 'dün';

  @override
  String relativeDaysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get profileSectionAllergies => 'Alerjilerim';

  @override
  String get profileSectionDiet => 'Beslenme düzenim';

  @override
  String get profileSectionHealth => 'Sağlık durumum';

  @override
  String get shoppingListsTitle => 'Alışveriş Listelerim';

  @override
  String get seeAllUpper => 'Tümünü Gör';

  @override
  String get noShoppingListsTitle => 'Henüz Listeniz Yok';

  @override
  String get noShoppingListsPrompt =>
      'Dokunun ve ilk alışveriş listenizi oluşturun';

  @override
  String get createListTitle => 'Yeni Liste Oluştur';

  @override
  String get listNameHint => 'Liste Adı (Örn: Hafta Sonu Pazarı)';

  @override
  String get createAction => 'Oluştur';

  @override
  String listCreated(String name) {
    return '\"$name\" listesi oluşturuldu.';
  }

  @override
  String get newListTooltip => 'Yeni Liste';

  @override
  String get noShoppingListsScreenTitle => 'Henüz bir alışveriş listeniz yok';

  @override
  String get noShoppingListsScreenBody =>
      'Market veya pazar alışverişlerinizi kolayca planlamak için yeni bir liste oluşturabilirsiniz.';

  @override
  String listItemsSummary(int total, int bought) {
    return '$total ürün • $bought alındı';
  }

  @override
  String get deleteListTitle => 'Listeyi Sil';

  @override
  String get deleteListConfirm =>
      'Bu alışveriş listesini ve içindeki tüm ürünleri silmek istediğinize emin misiniz?';

  @override
  String get deleteConfirmAction => 'Evet, Sil';

  @override
  String get listDeleted => 'Liste silindi.';

  @override
  String get listDetailTitle => 'Liste Detayı';

  @override
  String get shoppingProgress => 'Alışveriş İlerlemesi';

  @override
  String progressBought(int bought, int total) {
    return '$bought / $total Alındı';
  }

  @override
  String get noItemsTitle => 'Bu listede henüz ürün yok';

  @override
  String get noItemsBody =>
      'Aşağıdaki \"Ürün Ekle\" butonuna dokunarak son tarananlardan veya arama ile ürün ekleyebilirsiniz.';

  @override
  String get addProduct => 'Ürün Ekle';

  @override
  String itemAdded(String name) {
    return '\"$name\" listeye eklendi.';
  }

  @override
  String get itemAddFailed => 'Ürün eklenirken bir hata oluştu.';

  @override
  String get addProductToList => 'Listeye Ürün Ekle';

  @override
  String get tabRecentScans => 'Son Tarananlar';

  @override
  String get tabSearchManual => 'Arama & Elle Ekle';

  @override
  String get noRecentScansTitle => 'Henüz taranmış ürün bulunmuyor.';

  @override
  String get noRecentScansBody =>
      'Barkod tarayarak ürün incelediğinizde öneriler burada görünecektir.';

  @override
  String get manualAddTitle => 'Elle Ürün Adı Gir';

  @override
  String get manualNameHint => 'Örn: Süt, Elma, Yulaf...';

  @override
  String get searchByNameTitle => 'Ürün İsmine Göre Ara';

  @override
  String get searchByNameHint => 'Marka veya ürün adı ara...';

  @override
  String get medicalDisclaimerShort =>
      'Bu bilgi tıbbi tavsiye niteliği taşımaz.';
}
