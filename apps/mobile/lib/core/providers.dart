import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/product_repository.dart';
import '../features/auth/auth_viewmodel.dart';
import '../features/scan/scan_viewmodel.dart';
import '../data/repositories/scan_history_repository.dart';
import '../features/dashboard/dashboard_viewmodel.dart';
import '../features/home/home_viewmodel.dart';

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

final scanHistoryRepositoryProvider = Provider<ScanHistoryRepository>((ref) {
  return ScanHistoryRepository(Supabase.instance.client);
});


final dashboardViewModelProvider = ChangeNotifierProvider<DashboardViewModel>((ref) {
  return DashboardViewModel(ref.watch(scanHistoryRepositoryProvider));
});

final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>((ref) {
  return HomeViewModel(ref.watch(scanHistoryRepositoryProvider));
});
