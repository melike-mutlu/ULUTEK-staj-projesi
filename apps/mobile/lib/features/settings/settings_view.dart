import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Ayarlar — profil ekranının sağ üstündeki dişli ikonundan açılır.
///
/// Şimdilik tek satır: çıkış. Yeni ayarlar [_SettingsRow] eklenerek büyür;
/// satırlar tek tip olsun diye ayrı bir widget'a alındı.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await supabase.auth.signOut();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Çıkış yapılamadı. Lütfen tekrar dene.')),
      );
      return;
    }
    // Oturum kapandı: geri tuşuyla içeri dönülemesin diye yığın sıfırlanır.
    navigator.pushNamedAndRemoveUntil(AppRoutes.auth, (Route<void> _) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text('Ayarlar', style: AppTextStyles.heading2),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: <Widget>[
            _SettingsRow(
              icon: Icons.logout_rounded,
              label: 'Çıkış yap',
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ayarlar listesindeki tek satır — ikon + etiket + ok.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppTextStyles.title)),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
