import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/profile_options.dart';
import '../../core/models/user_profile.dart';
import '../../core/utils/display_name.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/services/image_picker_service.dart';

/// Onboarding'de girilen profili sonradan düzenlemek için.
///
/// `OnboardingViewModel` ile aynı desen: private state + getter'lar, seçim
/// taslağı ViewModel'de tutulur, View yalnızca çizer. Kaydetme çip başına
/// değil, tek "Kaydet" ile toplu yapılır.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._profileRepository, this._imagePickerService);

  final ProfileRepository _profileRepository;
  final ImagePickerService _imagePickerService;

  /// Ekranda gösterilen seçim taslağı — kaydedilene kadar yereldir.
  final Map<OnboardingField, Set<String>> _draft =
      <OnboardingField, Set<String>>{
    for (final field in OnboardingField.values) field: <String>{},
  };

  /// Katalogda olmayan ama gösterilmesi gereken seçenekler: kullanıcının "+"
  /// ile eklediği ve kayıtlı profilden gelen değerler. Ayrı tutulur ki sabit
  /// katalog kirlenmesin; [optionsFor] ikisini birleştirir.
  final Map<OnboardingField, List<String>> _extraOptions =
      <OnboardingField, List<String>>{
    for (final field in OnboardingField.values) field: <String>[],
  };

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  /// Kayıtlı ad. Taslak DEĞİL: kutu kapanır kapanmaz veritabanına yazılır.
  String? _displayName;

  bool _isSavingName = false;

  /// Fotoğraf URL'i taslak DEĞİL: yükleme başarılı olur olmaz kaydedilir,
  /// çünkü dosya o an zaten bucket'a gitmiş olur.
  String? _avatarUrl;

  /// Son [load] başarısız mı — View bunu tam ekran "tekrar dene" ile gösterir,
  /// kaydetme hatasını ise formun altındaki satırda.
  bool _loadFailed = false;

  /// En son yüklenen/kaydedilen hâl — [hasChanges] bununla karşılaştırır.
  UserProfile? _profile;

  String? _email;

  // --- Okuma ---

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get errorMessage => _errorMessage;
  bool get loadFailed => _loadFailed;

  /// Kutuya ön değer olarak konur — yedek (e-posta) isim değil, gerçek ad.
  String get displayNameDraft => _displayName ?? '';
  String? get avatarUrl => _avatarUrl;
  bool get isSavingName => _isSavingName;

  /// Başlıkta gösterilecek ad: girilen ad, yoksa e-posta kullanıcı adı.
  String get resolvedDisplayName => resolveDisplayName(
        displayName: _displayName,
        email: _email,
      );

  /// Oturumdaki e-posta — [load] sırasında okunup saklanır ki build tarafı
  /// Supabase'e hiç dokunmasın.
  String? get email => _email;
  UserProfile? get profile => _profile;

  /// Sabit katalog + profilden gelen/kullanıcının eklediği seçenekler.
  List<String> optionsFor(OnboardingField field) => <String>[
        ...profileOptions[field]!,
        ..._extraOptions[field]!,
      ];

  Set<String> selectionsFor(OnboardingField field) => _draft[field]!;

  bool isSelected(OnboardingField field, String option) =>
      _draft[field]!.contains(option);

  /// Kaydedilmemiş değişiklik var mı — "Kaydet" butonu buna bakar.
  ///
  /// Yalnızca çip seçimlerine bakar: ad ve fotoğraf kendi akışlarında anında
  /// kaydedilir, bu butonu beklemezler.
  bool get hasChanges {
    final profile = _profile;
    if (profile == null) {
      return _draft.values.any((Set<String> selected) => selected.isNotEmpty);
    }
    return !setEquals(
          _draft[OnboardingField.allergies],
          profile.allergies.toSet(),
        ) ||
        !setEquals(
          _draft[OnboardingField.health],
          profile.healthConditions.toSet(),
        ) ||
        !setEquals(
          _draft[OnboardingField.diet],
          profile.dietPreferences.toSet(),
        );
  }

  // --- Yazma ---

  /// Adı hemen kaydeder — alttaki "Kaydet" butonunu beklemez.
  /// Boş/whitespace girdi "ad yok" demektir ve kabul edilir; ad zorunlu değil.
  ///
  /// Kaydedilmemiş çip taslağını yazmaz: satırın diğer alanları en son
  /// kaydedilmiş hâlinden kopyalanır.
  Future<bool> saveDisplayName(String value) async {
    final trimmed = value.trim();
    final normalized = trimmed.isEmpty ? null : trimmed;
    if (normalized == _displayName) return true;

    final String? userId;
    try {
      userId = _profileRepository.currentUserId;
    } catch (error, stackTrace) {
      _failWith('Ad kaydedilemedi. Lütfen tekrar dene.', error, stackTrace);
      notifyListeners();
      return false;
    }
    if (userId == null) {
      _errorMessage = 'Oturum bulunamadı. Lütfen tekrar giriş yap.';
      notifyListeners();
      return false;
    }

    _isSavingName = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = _profileWith(
        userId: userId,
        displayName: normalized,
        avatarUrl: _avatarUrl,
      );
      await _profileRepository.saveProfile(updated);
      _profile = updated;
      _displayName = normalized;
      _isSavingName = false;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      _isSavingName = false;
      _failWith('Ad kaydedilemedi. Lütfen tekrar dene.', error, stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// En son kaydedilmiş satırın kopyası, verilen alan(lar) değiştirilmiş hâlde.
  ///
  /// Her iki alan da zorunlu: burada null "değiştirme" değil "temizle" demek,
  /// o yüzden çağıran taraf ikisini de açıkça vermek zorunda. `copyWith` tarzı
  /// bir yardımcı adı temizlemeye izin vermezdi.
  UserProfile _profileWith({
    required String userId,
    required String? displayName,
    required String? avatarUrl,
  }) {
    final base = _profile;
    return UserProfile(
      userId: userId,
      allergies: base?.allergies ?? const <String>[],
      dietPreferences: base?.dietPreferences ?? const <String>[],
      healthConditions: base?.healthConditions ?? const <String>[],
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  /// Galeriden fotoğraf seçtirir, bucket'a yükler ve profile hemen yazar.
  ///
  /// Seçimlerin aksine beklemeye alınmaz: dosya yüklendiği anda bucket'ta olur,
  /// URL'i sadece bellekte tutmak "Kaydet"e basılmazsa onu kaybettirirdi.
  /// Kaydedilmemiş seçim taslağı bundan etkilenmez — yazılan satır en son
  /// kaydedilmiş hâlin üstüne yalnızca yeni URL'i ekler.
  Future<void> pickAndUploadAvatar() async {
    final String? userId;
    try {
      userId = _profileRepository.currentUserId;
    } catch (error, stackTrace) {
      _failWith('Fotoğraf yüklenemedi. Lütfen tekrar dene.', error, stackTrace);
      notifyListeners();
      return;
    }
    if (userId == null) {
      _errorMessage = 'Oturum bulunamadı. Lütfen tekrar giriş yap.';
      notifyListeners();
      return;
    }

    try {
      final picked = await _imagePickerService.pickFromGallery();
      // Kullanıcı vazgeçti — hata değil, sessizce çık.
      if (picked == null) return;

      _isUploadingAvatar = true;
      _errorMessage = null;
      notifyListeners();

      final url = await _profileRepository.uploadAvatar(
        userId: userId,
        bytes: picked.bytes,
        fileExtension: picked.extension,
      );

      final updated = _profileWith(
        userId: userId,
        displayName: _displayName,
        avatarUrl: url,
      );

      await _profileRepository.saveProfile(updated);
      _profile = updated;
      _avatarUrl = url;
    } catch (error, stackTrace) {
      _failWith('Fotoğraf yüklenemedi. Lütfen tekrar dene.', error, stackTrace);
    }

    _isUploadingAvatar = false;
    notifyListeners();
  }

  /// Üç alan da çoklu seçim — `diet_preference` `text[]` olduğundan diyet de
  /// artık diğerleri gibi davranıyor.
  void toggleOption(OnboardingField field, String option) {
    final selected = _draft[field]!;
    if (!selected.remove(option)) selected.add(option);
    notifyListeners();
  }

  /// "+" çipiyle özel seçenek ekler; eklenen seçenek otomatik seçili gelir.
  /// Boş/whitespace ve mevcut seçenekle (case-insensitive) çakışan girdi
  /// reddedilir.
  ///
  /// Üç alanda da açık: `diet_preference` de `text[]` olduğu için özel diyet
  /// değerleri diğer alanlardaki gibi olduğu gibi kaydedilir.
  void addCustomOption(OnboardingField field, String option) {
    final trimmed = option.trim();
    if (trimmed.isEmpty) return;

    final alreadyExists = optionsFor(field).any(
      (String existing) => existing.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) return;

    _extraOptions[field]!.add(trimmed);
    _draft[field]!.add(trimmed);
    notifyListeners();
  }

  /// Kullanıcıya gösterilecek mesajı yazar, teknik detayı geliştirici
  /// konsoluna bırakır. Sessiz `catch (_)` bir backend değişikliğini (kolon
  /// tipi, RLS) fark edilmez hâle getiriyordu.
  void _failWith(String message, Object error, StackTrace stackTrace) {
    _errorMessage = message;
    if (kDebugMode) {
      debugPrint('ProfileViewModel: $message <- $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Kayıtlı profili çeker ve taslağı onunla doldurur.
  /// Profil satırı yoksa (onboarding'i atlamış veya misafir kullanıcı) bu bir hata değil —
  /// boş/varsayılan taslakla başlanır.
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _loadFailed = false;
    notifyListeners();

    try {
      final userId = _profileRepository.currentUserId;
      _email = _profileRepository.currentUserEmail;
      if (userId != null) {
        _profile = await _profileRepository.getProfile(userId);
      }
      _displayName = _profile?.displayName;
      _avatarUrl = _profile?.avatarUrl;
      _applyToDraft(_profile);
    } catch (error, stackTrace) {
      debugPrint('ProfileViewModel load warning: $error');
      _loadFailed = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Üç kategoriyi tek seferde kaydeder, başarıysa true döner.
  Future<bool> save() async {
    final String? userId = _profileRepository.currentUserId;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final effectiveUserId = userId ?? 'guest';
      final updated = UserProfile(
        userId: effectiveUserId,
        allergies: _draft[OnboardingField.allergies]!.toList(),
        dietPreferences: _draft[OnboardingField.diet]!.toList(),
        healthConditions: _draft[OnboardingField.health]!.toList(),
        displayName: _displayName,
        avatarUrl: _avatarUrl,
      );

      if (userId != null) {
        try {
          await _profileRepository.saveProfile(updated);
        } catch (e) {
          debugPrint('ProfileViewModel save warning (guest/RLS): $e');
        }
      }
      _profile = updated;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      _isSaving = false;
      _failWith('Profil kaydedilemedi. Lütfen tekrar dene.', error, stackTrace);
      notifyListeners();
      return false;
    }
  }

  // --- Yardımcılar ---

  void _applyToDraft(UserProfile? profile) {
    for (final selected in _draft.values) {
      selected.clear();
    }
    if (profile == null) return;

    _selectAll(OnboardingField.allergies, profile.allergies);
    _selectAll(OnboardingField.diet, profile.dietPreferences);
    _selectAll(OnboardingField.health, profile.healthConditions);
  }

  /// Kayıtlı değerleri seçili yapar; katalogda olmayanları (kullanıcının
  /// onboarding'de "+" ile eklediği "Kivi" gibi) seçenek listesine katar ki
  /// ekranda görünsünler ve ilk kayıtta sessizce silinmesinler.
  void _selectAll(OnboardingField field, List<String> values) {
    final catalog = optionsFor(field);
    for (final value in values) {
      if (!catalog.contains(value)) _extraOptions[field]!.add(value);
      _draft[field]!.add(value);
    }
  }
}

final profileViewModelProvider =
    ChangeNotifierProvider.autoDispose<ProfileViewModel>(
  (ref) => ProfileViewModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(imagePickerServiceProvider),
  ),
);
