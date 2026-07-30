import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/profile_repository.dart';
import '../features/onboarding/onboarding_viewmodel.dart';
import '../features/auth/auth_viewmodel.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final onboardingViewModelProvider =
    ChangeNotifierProvider<OnboardingViewModel>((ref) {
  return OnboardingViewModel(ref.watch(profileRepositoryProvider));
});

final authViewModelProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  return AuthViewModel();
}); 