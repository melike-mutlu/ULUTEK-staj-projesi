import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/explanation_repository.dart';
import '../data/repositories/product_search_repository.dart';
import '../data/repositories/product_cache_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../features/auth/auth_viewmodel.dart';
import '../features/search/search_viewmodel.dart';
import '../features/scan/scan_viewmodel.dart';
import '../data/repositories/scan_history_repository.dart';
import '../features/home/home_viewmodel.dart';
import '../features/chatbot/chatbot_viewmodel.dart';
import '../data/repositories/chatbot_repository.dart';
import '../core/supabase_client.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Feeds the LLM explanation into product detail. The verdict still comes from
/// the rule engine; this only supplies the human-readable text.
final explanationRepositoryProvider = Provider<ExplanationRepository>((ref) {
  return ExplanationRepository();
});

/// Product name search (Zeynep's OFF search). Mock data until the backend is
/// ready; only this repository's [searchByName] body changes then.
final productSearchRepositoryProvider =
    Provider<ProductSearchRepository>((ref) {
  return ProductSearchRepository();
});

final scanViewModelProvider = ChangeNotifierProvider<ScanViewModel>((ref) {
  return ScanViewModel(
    ref.watch(productRepositoryProvider), // Ürünü getiren
    ref.watch(
        scanHistoryRepositoryProvider), // Yeni eklediğimiz geçmişe kaydeden
  );
});

final authViewModelProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  return AuthViewModel();
});

/// Drives the product name search bar on the home screen.
final searchViewModelProvider = ChangeNotifierProvider<SearchViewModel>((ref) {
  return SearchViewModel(ref.watch(productSearchRepositoryProvider));
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

// ChatbotRepository'yi Riverpod ile sunan provider — global 'supabase'
// değişkenini veriyor.
final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  return ChatbotRepository(supabase);
});

final chatbotViewModelProvider =
    ChangeNotifierProvider<ChatbotViewModel>((ref) {
  final repository = ref.watch(chatbotRepositoryProvider);
  return ChatbotViewModel(repository);
});
