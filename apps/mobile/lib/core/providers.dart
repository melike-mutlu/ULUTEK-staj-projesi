import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../features/onboarding/onboarding_viewmodel.dart';
import '../features/scan/scan_viewmodel.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final onboardingViewModelProvider =
    ChangeNotifierProvider<OnboardingViewModel>((ref) {
  return OnboardingViewModel(ref.watch(profileRepositoryProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final scanViewModelProvider = ChangeNotifierProvider<ScanViewModel>((ref) {
  return ScanViewModel(ref.watch(productRepositoryProvider));
});