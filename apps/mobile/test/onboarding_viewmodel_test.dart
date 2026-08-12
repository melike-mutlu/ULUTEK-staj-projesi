import 'dart:typed_data';

import 'package:akilli_sepet/core/models/user_profile.dart';
import 'package:akilli_sepet/data/repositories/profile_repository.dart';
import 'package:akilli_sepet/features/onboarding/onboarding_steps.dart';
import 'package:akilli_sepet/features/onboarding/onboarding_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements ProfileRepository {
  UserProfile? savedProfile;

  @override
  String? currentUserId = 'test-user';

  @override
  String? currentUserEmail = 'test@example.com';

  @override
  Future<UserProfile?> getProfile(String userId) async => null;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    savedProfile = profile;
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async =>
      'https://example.invalid/avatars/$userId.$fileExtension';

  @override
  Future<void> deleteAccount() async {}
}

void main() {
  late _FakeProfileRepository repository;
  late OnboardingViewModel viewModel;

  setUp(() {
    repository = _FakeProfileRepository();
    viewModel = OnboardingViewModel(repository);
  });

  test('baslangic durumu: ilk adim, geri gidilemez, ilerleme 1/7', () {
    expect(viewModel.currentIndex, 0);
    expect(viewModel.canGoBack, isFalse);
    expect(viewModel.progress, 1 / 7);
  });

  test('goNext 6 kez son adima getirir, 7. cagri siniri asmaz', () {
    for (var i = 0; i < 6; i++) {
      viewModel.goNext();
    }
    expect(viewModel.isLastStep, isTrue);
    expect(viewModel.progress, 1.0);

    viewModel.goNext();
    expect(viewModel.currentIndex, 6);
    expect(viewModel.isLastStep, isTrue);
  });

  test('goBack sinirin altina inmez', () {
    viewModel.goBack();
    expect(viewModel.currentIndex, 0);
  });

  test('isim adiminda (index 2) setDisplayName ve primaryActionLabel mantigi', () {
    viewModel.goNext();
    viewModel.goNext(); // Index 2: OnboardingNameStep
    expect(viewModel.currentStep, isA<OnboardingNameStep>());
    expect(viewModel.primaryActionLabel, 'Atla');

    viewModel.setDisplayName('Ahmet');
    expect(viewModel.displayName, 'Ahmet');
    expect(viewModel.primaryActionLabel, 'Devam');
  });

  test('ulke adiminda (index 3) setCountry ve primaryActionLabel mantigi', () {
    viewModel.goNext();
    viewModel.goNext();
    viewModel.goNext(); // Index 3: OnboardingCountryStep
    expect(viewModel.currentStep, isA<OnboardingCountryStep>());
    expect(viewModel.primaryActionLabel, 'Atla');

    viewModel.setCountry('Türkiye');
    expect(viewModel.country, 'Türkiye');
    expect(viewModel.primaryActionLabel, 'Devam');
  });

  test('toggleOption secer/kaldirir, alanlar birbirini etkilemez', () {
    viewModel.toggleOption(OnboardingField.allergies, 'Gluten');
    expect(viewModel.isSelected(OnboardingField.allergies, 'Gluten'), isTrue);
    expect(viewModel.isSelected(OnboardingField.diet, 'Gluten'), isFalse);

    viewModel.toggleOption(OnboardingField.allergies, 'Gluten');
    expect(viewModel.isSelected(OnboardingField.allergies, 'Gluten'), isFalse);
  });

  test(
      'addCustomOption bos/tekrar eden girdiyi reddeder, gecerli olani ekler ve secili yapar',
      () {
    viewModel.addCustomOption(OnboardingField.allergies, '   ');
    expect(viewModel.optionsFor(OnboardingField.allergies), isNot(contains('')));

    final beforeCount = viewModel.optionsFor(OnboardingField.allergies).length;
    viewModel.addCustomOption(OnboardingField.allergies, 'gluten');
    expect(
      viewModel.optionsFor(OnboardingField.allergies).length,
      beforeCount,
    );

    viewModel.addCustomOption(OnboardingField.allergies, 'Kivi');
    expect(viewModel.optionsFor(OnboardingField.allergies), contains('Kivi'));
    expect(viewModel.isSelected(OnboardingField.allergies, 'Kivi'), isTrue);
  });

  test('primaryActionLabel: secim yokken skipLabel, secim varken Devam', () {
    viewModel.goNext();
    viewModel.goNext();
    viewModel.goNext();
    viewModel.goNext(); // Index 4: Allergies
    final step = viewModel.currentStep as OnboardingSelectionStep;
    expect(viewModel.primaryActionLabel, step.skipLabel);

    viewModel.toggleOption(step.field, step.options.first);
    expect(viewModel.primaryActionLabel, 'Devam');
  });

  test('submit() UserProfile alanlarini, displayName ve country\'yi dogru esler', () async {
    viewModel.goNext();
    viewModel.goNext(); // Index 2: Name step
    viewModel.setDisplayName('Ahmet');

    viewModel.goNext(); // Index 3: Country step
    viewModel.setCountry('Türkiye');

    viewModel.goNext(); // Index 4: Allergies
    viewModel.toggleOption(OnboardingField.allergies, 'Gluten');

    viewModel.goNext(); // Index 5: Diet
    viewModel.toggleOption(OnboardingField.diet, 'Vejetaryen');

    viewModel.goNext(); // Index 6: Health
    viewModel.toggleOption(OnboardingField.health, 'Tansiyon');

    final success = await viewModel.submit();
    expect(success, isTrue);
    expect(repository.savedProfile, isNotNull);
    expect(repository.savedProfile!.displayName, 'Ahmet');
    expect(repository.savedProfile!.country, 'Türkiye');
    expect(repository.savedProfile!.allergies, <String>['Gluten']);
    expect(repository.savedProfile!.healthConditions, <String>['Tansiyon']);
    expect(
      repository.savedProfile!.dietPreferences,
      <String>['Vejetaryen'],
    );
  });

  test('submit() currentUserId null ise kaydetmeyi atlar ama basarili doner',
      () async {
    repository.currentUserId = null;

    final success = await viewModel.submit();
    expect(success, isTrue);
    expect(repository.savedProfile, isNull);
  });
}
