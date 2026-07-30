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
  Future<UserProfile?> getProfile(String userId) async => null;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    savedProfile = profile;
  }
}

void main() {
  late _FakeProfileRepository repository;
  late OnboardingViewModel viewModel;

  setUp(() {
    repository = _FakeProfileRepository();
    viewModel = OnboardingViewModel(repository);
  });

  test('baslangic durumu: ilk adim, geri gidilemez, ilerleme 1/5', () {
    expect(viewModel.currentIndex, 0);
    expect(viewModel.canGoBack, isFalse);
    expect(viewModel.progress, 1 / 5);
  });

  test('goNext 4 kez son adima getirir, 5. cagri siniri asmaz', () {
    for (var i = 0; i < 4; i++) {
      viewModel.goNext();
    }
    expect(viewModel.isLastStep, isTrue);
    expect(viewModel.progress, 1.0);

    viewModel.goNext();
    expect(viewModel.currentIndex, 4);
    expect(viewModel.isLastStep, isTrue);
  });

  test('goBack sinirin altina inmez', () {
    viewModel.goBack();
    expect(viewModel.currentIndex, 0);
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
    final step = viewModel.currentStep as OnboardingSelectionStep;
    expect(viewModel.primaryActionLabel, step.skipLabel);

    viewModel.toggleOption(step.field, step.options.first);
    expect(viewModel.primaryActionLabel, 'Devam');
  });

  test('submit() UserProfile alanlarini dogru esler', () async {
    viewModel.goNext();
    viewModel.goNext();
    viewModel.toggleOption(OnboardingField.allergies, 'Gluten');

    viewModel.goNext();
    viewModel.toggleOption(OnboardingField.diet, 'Vejetaryen');

    viewModel.goNext();
    viewModel.toggleOption(OnboardingField.health, 'Tansiyon');

    final success = await viewModel.submit();
    expect(success, isTrue);
    expect(repository.savedProfile, isNotNull);
    expect(repository.savedProfile!.allergies, <String>['Gluten']);
    expect(repository.savedProfile!.healthConditions, <String>['Tansiyon']);
    expect(repository.savedProfile!.dietPreference, DietPreference.vejetaryen);
  });

  test('submit() currentUserId null ise kaydetmeyi atlar ama basarili doner',
      () async {
    repository.currentUserId = null;

    final success = await viewModel.submit();
    expect(success, isTrue);
    expect(repository.savedProfile, isNull);
  });
}
