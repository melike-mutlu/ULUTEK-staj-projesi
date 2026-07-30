import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_repository.dart';
import '../features/auth/auth_viewmodel.dart';
import '../features/scan/scan_viewmodel.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final scanViewModelProvider = ChangeNotifierProvider<ScanViewModel>((ref) {
  return ScanViewModel(ref.watch(productRepositoryProvider));
});

final authViewModelProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  return AuthViewModel();
});
