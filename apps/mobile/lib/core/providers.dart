import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_cache_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../features/auth/auth_viewmodel.dart';
import '../features/scan/scan_viewmodel.dart';
import '../data/repositories/scan_history_repository.dart';
import '../features/home/home_viewmodel.dart';
import '../features/chatbot/chatbot_viewmodel.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final scanViewModelProvider = ChangeNotifierProvider<ScanViewModel>((ref) {
  return ScanViewModel(
    ref.watch(productRepositoryProvider), // Ürünü getiren
    ref.watch(scanHistoryRepositoryProvider), // Yeni eklediğimiz geçmişe kaydeden
  );
});

final authViewModelProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  return AuthViewModel();
});

final productCacheRepositoryProvider = Provider<ProductCacheRepository>((ref) {
  return ProductCacheRepository();
});

final scanHistoryRepositoryProvider = Provider<ScanHistoryRepository>((ref) {
  return ScanHistoryRepository(
    productCacheRepository: ref.watch(productCacheRepositoryProvider),
  );
});


final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>((ref) {
  return HomeViewModel(
    ref.watch(scanHistoryRepositoryProvider),
    ref.watch(profileRepositoryProvider),
  );
});

final chatbotViewModelProvider = ChangeNotifierProvider<ChatbotViewModel>((ref) {
  return ChatbotViewModel(ref.watch(scanHistoryRepositoryProvider));
});
