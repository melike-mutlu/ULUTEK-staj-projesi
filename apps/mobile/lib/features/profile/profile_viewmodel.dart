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

  /// Ad taslağı — seçimler gibi "Kaydet"e kadar yerel. Boş string "ad girilmedi"
  /// demek; kaydederken null'a çevrilir.
  String _displayNameDraft = '';

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

  String get displayNameDraft => _displayNameDraft;
  String? get avatarUrl => _avatarUrl;

  /// Başlıkta gösterilecek ad: girilen ad, yoksa e-posta kullanıcı adı.
  String get resolvedDisplayName => resolveDisplayName(
        displayName: _displayNameDraft,
        email: _email,
      );

  /// Oturumdaki e-posta — [load] sırasında okunup saklanır ki build tarafı
  /// Supabase'e hiç dokunmasın.
  String? get email => _email;
  UserProfile? get profile => _profile;

  /// Sabit katalog + profilden gelen/kullanıcının eklediği seçenekler.
  /// Diyet için yalnızca veritabanına yazılabilen etiketler döner.
  List<String> optionsFor(OnboardingField field) => <String>[
        ...(field == OnboardingField.diet
            ? profileDietOptions
            : profileOptions[field]!),
        ..._extraOptions[field]!,
      ];

  Set<String> selectionsFor(OnboardingField field) => _draft[field]!;

  bool isSelected(OnboardingField field, String option) =>
      _draft[field]!.contains(option);

  /// Kaydedilmemiş değişiklik var mı — "Kaydet" butonu buna bakar.
  bool get hasChanges {
    final profile = _profile;
    if (profile == null) {
      return _displayNameDraft.isNotEmpty ||
          _draft.values.any((Set<String> selected) => selected.isNotEmpty);
    }
    return _displayNameDraft != (profile.displayName ?? '') ||
        !setEquals(
          _draft[OnboardingField.allergies],
          profile.allergies.toSet(),
        ) ||
        !setEquals(
          _draft[OnboardingField.health],
          profile.healthConditions.toSet(),
        ) ||
        _draftDietPreference != profile.dietPreference;
  }

  // --- Yazma ---

  /// Adı taslağa yazar; kalıcı olması için "Kaydet" gerekir.
  /// Boş/whitespace girdi "ad yok" demektir ve kabul edilir — ad zorunlu değil.
  void setDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed == _displayNameDraft) return;
    _displayNameDraft = trimmed;
    notifyListeners();
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
    } catch (_) {
      _errorMessage = 'Fotoğraf yüklenemedi. Lütfen tekrar dene.';
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

      final updated = (_profile ??
              UserProfile(
                userId: userId,
                allergies: const <String>[],
                dietPreference: DietPreference.standard,
                healthConditions: const <String>[],
              ))
          .copyWith(avatarUrl: url);

      await _profileRepository.saveProfile(updated);
      _profile = updated;
      _avatarUrl = url;
    } catch (_) {
      _errorMessage = 'Fotoğraf yüklenemedi. Lütfen tekrar dene.';
    }

    _isUploadingAvatar = false;
    notifyListeners();
  }

  /// Diyet tek seçimlidir: yeni seçim öncekinin yerine geçer (veritabanındaki
  /// tekil enum ile birebir olsun diye). Diğer alanlar çoklu seçim.
  void toggleOption(OnboardingField field, String option) {
    final selected = _draft[field]!;
    final wasSelected = selected.contains(option);

    if (field == OnboardingField.diet) {
      selected.clear();
      if (!wasSelected) selected.add(option);
    } else if (wasSelected) {
      selected.remove(option);
    } else {
      selected.add(option);
    }
    notifyListeners();
  }

  /// "+" çipiyle özel seçenek ekler; eklenen seçenek otomatik seçili gelir.
  /// Boş/whitespace ve mevcut seçenekle (case-insensitive) çakışan girdi
  /// reddedilir.
  ///
  /// Diyet tek seçimli olduğu için yalnızca hiçbir şey seçili değilken izin
  /// verilir; aksi hâlde eklenen seçenek mevcut tercihin yerine geçerdi.
  ///
  /// TODO(backend-pod): katalog dışı bir diyet etiketinin `DietPreference`
  /// karşılığı yok, kaydedilince `standard` olarak gidiyor. `diet_preference`
  /// `text[]`e genişleyince (bkz. dietPreferenceByLabel) burası düzelir.
  void addCustomOption(OnboardingField field, String option) {
    if (field == OnboardingField.diet && _draft[field]!.isNotEmpty) return;

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

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Kayıtlı profili çeker ve taslağı onunla doldurur.
  /// Profil satırı yoksa (onboarding'i atlamış kullanıcı) bu bir hata değil —
  /// boş taslakla başlanır.
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _loadFailed = false;
    notifyListeners();

    // Oturum erişimi de try içinde: Supabase hazır değilse ekran çökmesin,
    // hata durumuna düşsün.
    try {
      final userId = _profileRepository.currentUserId;
      if (userId == null) {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = 'Oturum bulunamadı. Lütfen tekrar giriş yap.';
        notifyListeners();
        return;
      }
      _email = _profileRepository.currentUserEmail;
      _profile = await _profileRepository.getProfile(userId);
      _displayNameDraft = _profile?.displayName ?? '';
      _avatarUrl = _profile?.avatarUrl;
      _applyToDraft(_profile);
    } catch (_) {
      _loadFailed = true;
      _errorMessage = 'Profil yüklenemedi. Lütfen tekrar dene.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Üç kategoriyi tek seferde kaydeder, başarıysa true döner.
  Future<bool> save() async {
    final String? userId;
    try {
      userId = _profileRepository.currentUserId;
    } catch (_) {
      _errorMessage = 'Profil kaydedilemedi. Lütfen tekrar dene.';
      notifyListeners();
      return false;
    }
    if (userId == null) {
      _errorMessage = 'Oturum bulunamadı. Lütfen tekrar giriş yap.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Tüm alanlar açıkça veriliyor: saveProfile satırın tamamını upsert eder,
      // eksik bırakılan alan veritabanında null'lanırdı.
      final updated = UserProfile(
        userId: userId,
        allergies: _draft[OnboardingField.allergies]!.toList(),
        dietPreference: _draftDietPreference,
        healthConditions: _draft[OnboardingField.health]!.toList(),
        displayName: _displayNameDraft.isEmpty ? null : _displayNameDraft,
        avatarUrl: _avatarUrl,
      );
      await _profileRepository.saveProfile(updated);
      _profile = updated;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSaving = false;
      _errorMessage = 'Profil kaydedilemedi. Lütfen tekrar dene.';
      notifyListeners();
      return false;
    }
  }

  // --- Yardımcılar ---

  /// Taslaktaki tekil diyet seçimi; seçim yoksa `standard`.
  DietPreference get _draftDietPreference {
    final selected = _draft[OnboardingField.diet]!;
    if (selected.isEmpty) return DietPreference.standard;
    return dietPreferenceByLabel[selected.first] ?? DietPreference.standard;
  }

  void _applyToDraft(UserProfile? profile) {
    for (final selected in _draft.values) {
      selected.clear();
    }
    if (profile == null) return;

    _selectAll(OnboardingField.allergies, profile.allergies);
    _selectAll(OnboardingField.health, profile.healthConditions);

    // Enum → etiket; `standard` bir seçenek değil, "seçim yok" demek.
    final dietLabel = dietPreferenceByLabel.entries
        .where((MapEntry<String, DietPreference> e) =>
            e.value == profile.dietPreference)
        .map((MapEntry<String, DietPreference> e) => e.key)
        .firstOrNull;
    if (dietLabel != null) _draft[OnboardingField.diet]!.add(dietLabel);
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
