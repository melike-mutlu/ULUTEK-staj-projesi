import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alt navigasyondaki sekmeler. Buradaki sıra ekrandaki sırayı belirler:
/// Ana Sayfa · Tara · Geçmiş · Profil.
enum ShellTab { dashboard, scan, home, profile }

/// Alt navigasyon kabuğunun state'i — hangi sekme açık.
///
/// Repodaki ilk provider bağlantısı burada; diğer ViewModel'ler de aynı deseni
/// izleyebilir: `ChangeNotifier` + `ChangeNotifierProvider`, View tarafında
/// `ConsumerWidget` + `ref.watch(...)`.
class ShellViewModel extends ChangeNotifier {
  ShellTab _currentTab = ShellTab.dashboard;

  ShellTab get currentTab => _currentTab;

  /// [IndexedStack]'in beklediği sekme sırası.
  int get currentIndex => _currentTab.index;

  void selectTab(ShellTab tab) {
    if (tab == _currentTab) return;
    _currentTab = tab;
    notifyListeners();
  }
}

final shellViewModelProvider =
    ChangeNotifierProvider<ShellViewModel>((ref) => ShellViewModel());
