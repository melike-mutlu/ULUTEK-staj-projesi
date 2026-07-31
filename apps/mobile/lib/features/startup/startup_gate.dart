import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/error_state_view.dart';

/// Uygulamanın ilk ekranı: oturuma ve profil satırına bakıp nereye gidileceğine
/// karar verir. Karar verilene kadar spinner gösterir.
///
///  - oturum yok                    -> /auth
///  - oturum var, profil satırı var -> /shell
///  - oturum var, satır yok         -> /onboarding (yeni kayıt)
///
/// The session is already restored when this runs: `Supabase.initialize()` is
/// awaited in main() and it awaits the persisted session, so `currentUserId` is
/// reliable here. Only the profile lookup is async.
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    if (mounted && _failed) setState(() => _failed = false);

    final repository = ref.read(profileRepositoryProvider);

    final String? userId;
    try {
      userId = repository.currentUserId;
    } catch (_) {
      // Supabase not initialized (e.g. widget tests): treat as signed out.
      _go(AppRoutes.auth);
      return;
    }

    if (userId == null) {
      _go(AppRoutes.auth);
      return;
    }

    try {
      final profile = await repository.getProfile(userId);
      // A missing row means the user never finished onboarding. A failed read
      // must NOT land here: onboarding would overwrite an existing profile.
      _go(profile == null ? AppRoutes.onboarding : AppRoutes.shell);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _go(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {
      // Already signed out locally is good enough to leave the dead end.
    }
    _go(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _failed
            ? ErrorStateView(
                message: 'Profilin yüklenemedi. Bağlantını kontrol edip '
                    'tekrar dene.',
                onRetry: _decide,
                secondaryLabel: 'Çıkış yap',
                onSecondary: _signOut,
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
