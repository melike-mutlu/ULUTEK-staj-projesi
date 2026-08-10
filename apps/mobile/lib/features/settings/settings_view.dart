import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user_profile.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/profile_repository.dart';
import '../profile/profile_viewmodel.dart';

/// Ayarlar — profil ekranının sağ üstündeki dişli ikonundan açılır.
class SettingsView extends ConsumerWidget {
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

  void _navigateToProfile(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  Future<void> _togglePremium(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(profileRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final userId = repo.currentUserId;
    if (userId == null) return;

    try {
      final currentProfile = await repo.getProfile(userId);
      final isCurrentlyPremium = currentProfile?.isPremium ?? false;
      final updatedProfile = UserProfile(
        userId: userId,
        allergies: currentProfile?.allergies ?? const <String>[],
        dietPreferences: currentProfile?.dietPreferences ?? const <String>[],
        healthConditions: currentProfile?.healthConditions ?? const <String>[],
        displayName: currentProfile?.displayName,
        avatarUrl: currentProfile?.avatarUrl,
        isPremium: !isCurrentlyPremium,
      );
      await repo.saveProfile(updatedProfile);
      await ref.read(homeViewModelProvider).loadDashboardData();
      // ProfileViewModel de yenilenmeli — chatbot'un paywall kontrolü onun
      // önbelleğindeki profile bakıyor, yoksa kilit hemen açılmaz.
      await ref.read(profileViewModelProvider).load();

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              !isCurrentlyPremium
                  ? 'Premium aktif edildi!'
                  : 'Premium devre dışı bırakıldı.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Premium durumu güncellenemedi.')),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.brand),
              SizedBox(width: 10),
              Text('Hakkında', style: AppTextStyles.title),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akıllı Sepet — Versiyon 1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ULUTEK Staj Projesi kapsamında geliştirilmiş, barkod tarama ve yapay zeka destekli akıllı ürün analiz asistanıdır.',
                style: AppTextStyles.body,
              ),
              SizedBox(height: 12),
              Text(
                'Kullanıcıların alerji, diyet ve özel sağlık tercihlerine göre ürün içeriklerini otomatik değerlendirir ve kişiselleştirilmiş uyarılarda bulunur.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Kapat', style: TextStyle(color: AppColors.brand)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.brand),
              SizedBox(width: 10),
              Text('Gizlilik Politikası', style: AppTextStyles.title),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veri Gizliliği ve Güvenliği',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Akıllı Sepet uygulaması, seçtiğiniz diyet, alerji ve sağlık verilerini yalnızca size özel ürün analizi yapabilmek amacıyla Supabase veritabanında güvenli bir şekilde saklar.',
                  style: AppTextStyles.body,
                ),
                SizedBox(height: 10),
                Text(
                  'Kişisel verileriniz hiçbir koşulda 3. taraflarla paylaşılmaz. İstediğiniz zaman profilinizden bilgilerinizi güncelleyebilirsiniz.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Anladım', style: TextStyle(color: AppColors.brand)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard() {
    final email = supabase.auth.currentUser?.email ?? 'Kullanıcı Hesabı';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.brandSoft,
            child: Icon(Icons.person_rounded, color: AppColors.brand, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: AppTextStyles.title,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Aktif Oturum',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(homeViewModelProvider).isPremium;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: <Widget>[
            _buildUserCard(),
            const SizedBox(height: 24),
            const _SettingsSectionHeader(title: 'HESAP & PROFİL'),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.person_outline_rounded,
              label: 'Profil Bilgilerini Düzenle',
              onTap: () => _navigateToProfile(context),
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.workspace_premium_outlined,
              iconColor: isPremium ? const Color(0xFFFFB300) : null,
              label: isPremium ? 'Premium\'dan Çık' : 'Premium\'a Geç',
              subtitle: isPremium ? 'Aktif' : 'Test Amaçlı',
              onTap: () => _togglePremium(context, ref),
            ),
            const SizedBox(height: 24),
            const _SettingsSectionHeader(title: 'UYGULAMA & YASAL'),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.shield_outlined,
              label: 'Gizlilik Politikası',
              onTap: () => _showPrivacyDialog(context),
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.info_outline_rounded,
              label: 'Hakkında',
              subtitle: 'v1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
            const SizedBox(height: 24),
            const _SettingsSectionHeader(title: 'OTURUM'),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.logout_rounded,
              label: 'Çıkış Yap',
              isDestructive: true,
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Ayarlar listesindeki tek satır — ikon + etiket + opsiyonel alt başlık/ok.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.subtitle,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.warning : AppColors.textPrimary;
    final effectiveIconColor = iconColor ?? color;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: effectiveIconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.title.copyWith(color: color),
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive ? AppColors.warning : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
