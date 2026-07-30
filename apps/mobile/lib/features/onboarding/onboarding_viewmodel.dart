import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';
import 'onboarding_steps.dart';

/// Onboarding akışının adım + seçim state'i. `ShellViewModel` ile aynı desen
/// (`ChangeNotifier` + `ChangeNotifierProvider`, View tarafında `ConsumerWidget`
/// + `ref.watch`).
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel(this._profileRepository);

  final ProfileRepository _profileRepository;

  /// Alan başına sabit seçenekler — `onboardingSteps`'ten tek sefer çıkarılır.
  static final Map<OnboardingField, OnboardingSelectionStep> _stepsByField =
      <OnboardingField, OnboardingSelectionStep>{
    for (final step in onboardingSteps.whereType<OnboardingSelectionStep>())
      step.field: step,
  };

  int _currentIndex = 0;

  final Map<OnboardingField, Set<String>> _selections =
      <OnboardingField, Set<String>>{
    for (final field in OnboardingField.values) field: <String>{},
  };

  /// Kullanıcının "+" ile eklediği seçenekler — sabit `options` listesine
  /// karışmasın diye ayrı tutulur, `optionsFor` ikisini birleştirir.
  final Map<OnboardingField, List<String>> _customOptions =
      <OnboardingField, List<String>>{
    for (final field in OnboardingField.values) field: <String>[],
  };

  bool _isSaving = false;
  String? _errorMessage;

  // --- Okuma ---

  int get currentIndex => _currentIndex;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  OnboardingStep get currentStep => onboardingSteps[_currentIndex];
  int get stepCount => onboardingSteps.length;
  double get progress => (_currentIndex + 1) / stepCount;
  bool get canGoBack => _currentIndex > 0;
  bool get isLastStep => _currentIndex == stepCount - 1;

  /// Sadece seçim ekranları için ilerleme oranı (3 adım, karşılama ekranları
  /// sayılmaz). Karşılama adımlarında progress bar hiç çizilmediği için
  /// (bkz. `onboarding_view.dart`) yalnızca bir seçim adımındayken çağrılır.
  double get selectionProgress {
    final selectionSteps =
        onboardingSteps.whereType<OnboardingSelectionStep>().toList();
    final index =
        selectionSteps.indexOf(currentStep as OnboardingSelectionStep);
    return (index + 1) / selectionSteps.length;
  }

  /// Sabit seçenekler + kullanıcının "+" ile eklediği seçenekler.
  List<String> optionsFor(OnboardingField field) => <String>[
        ..._stepsByField[field]!.options,
        ..._customOptions[field]!,
      ];

  Set<String> selectionsFor(OnboardingField field) => _selections[field]!;

  bool isSelected(OnboardingField field, String option) =>
      _selections[field]!.contains(option);

  /// Alt butonun metni: karşılama adımında `ctaLabel`, seçim adımında hiç
  /// seçim yoksa `skipLabel`, varsa "Devam".
  String get primaryActionLabel {
    final step = currentStep;
    return switch (step) {
      OnboardingWelcomeStep(:final ctaLabel) => ctaLabel ?? '',
      OnboardingSelectionStep() =>
        _selections[step.field]!.isEmpty ? step.skipLabel : 'Devam',
    };
  }

  // --- Yazma ---

  void toggleOption(OnboardingField field, String option) {
    final selected = _selections[field]!;
    if (!selected.add(option)) {
      selected.remove(option);
    }
    notifyListeners();
  }

  /// "+" çipiyle özel seçenek ekler. Boş/whitespace ve mevcut seçenekle
  /// (case-insensitive) çakışan girdi reddedilir; eklenen seçenek otomatik
  /// seçili gelir.
  void addCustomOption(OnboardingField field, String option) {
    final trimmed = option.trim();
    if (trimmed.isEmpty) return;

    final alreadyExists = optionsFor(field).any(
      (existing) => existing.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) return;

    _customOptions[field]!.add(trimmed);
    _selections[field]!.add(trimmed);
    notifyListeners();
  }

  void goNext() {
    if (_currentIndex >= stepCount - 1) return;
    _currentIndex++;
    notifyListeners();
  }

  void goBack() {
    if (_currentIndex <= 0) return;
    _currentIndex--;
    notifyListeners();
  }

  /// Karşılama ekranları arasında parmakla kaydırınca çağrılır — currentIndex'i
  /// doğrudan verilen adıma eşitler. Karşılama `PageView`'i kendi geçiş
  /// animasyonunu kendisi yaptığı için burada yalnızca state senkronlanır
  /// (dots + "Başlayalım" butonunun görünürlüğü currentIndex'e bağlı).
  void goToStep(int index) {
    if (index < 0 || index >= stepCount) return;
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// "Skip" linkine basılınca karşılama ekranlarını atlayıp ilk seçim
  /// ekranına geçer.
  void skipWelcome() {
    final targetIndex = onboardingSteps.indexWhere(
      (OnboardingStep step) => step is! OnboardingWelcomeStep,
    );
    if (targetIndex == -1 || targetIndex <= _currentIndex) return;
    _currentIndex = targetIndex;
    notifyListeners();
  }

  /// Dismisses the inline error without retrying the save.
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Profili kaydeder, başarıysa true döner.
  Future<bool> submit() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _profileRepository.currentUserId;
      // TODO(auth): email/password login ships before onboarding, so by the
      // time we get here there is a valid session and currentUserId is
      // non-null. This branch is only a safety fallback and should not trigger
      // in the normal flow — once login is wired, decide whether a missing user
      // should surface an error instead of silently skipping the save.
      if (userId != null) {
        final profile = UserProfile(
          userId: userId,
          allergies: _selections[OnboardingField.allergies]!.toList(),
          dietPreference: _mapDietPreference(
            _selections[OnboardingField.diet]!,
          ),
          healthConditions: _selections[OnboardingField.health]!.toList(),
        );
        await _profileRepository.saveProfile(profile);
      }
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

  /// Çoklu diyet seçimini sözleşmedeki tekil `diet_preference` enum'una indirger.
  ///
  /// UYARI — bilinçli veri kaybı: seçilen ilk eşleşen değer alınır, kalanlar
  /// düşer. Sözleşme `diet_preference`'ı tekil enum tanımlıyor
  /// (docs/architecture.md).
  /// TODO(backend-pod): `diet_preference` alanının `text[]`e genişletilmesi ya
  /// da `diet_tags text[]` eklenmesi konuşulacak; genişlerse burası tek
  /// satırlık değişir.
  DietPreference _mapDietPreference(Set<String> selections) {
    const mapping = <String, DietPreference>{
      'Vegan': DietPreference.vegan,
      'Vejetaryen': DietPreference.vejetaryen,
      'Diyabet dostu': DietPreference.diyabetDostu,
      'Sporcu / Yüksek protein': DietPreference.sporcu,
    };
    for (final entry in mapping.entries) {
      if (selections.contains(entry.key)) return entry.value;
    }
    return DietPreference.standard;
  }
}

final onboardingViewModelProvider =
    ChangeNotifierProvider.autoDispose<OnboardingViewModel>(
  (ref) => OnboardingViewModel(ref.watch(profileRepositoryProvider)),
);
