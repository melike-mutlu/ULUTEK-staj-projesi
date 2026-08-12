import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/user_profile.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_viewmodel.dart';
import '../../core/utils/email_masker.dart';
import '../../data/repositories/profile_repository.dart';
import '../profile/profile_viewmodel.dart';
import 'widgets/country_edit_dialog.dart';

/// Ayarlar — profil ekranının sağ üstündeki dişli ikonundan açılır.
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileViewModelProvider).load();
      }
    });
  }

  Future<void> _signOut() async {
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

  void _navigateToProfile() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  Future<void> _editCountry() async {
    final profileVm = ref.read(profileViewModelProvider);
    final initialCountry = profileVm.countryDraft;

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => CountryEditDialog(
        initialCountry: initialCountry,
      ),
    );

    if (result == null) return;

    final saved = await profileVm.saveCountry(result);
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ülke seçimi güncellendi.')),
    );
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
        country: currentProfile?.country,
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

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isObscured = true;
    bool isSubmitting = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: AppColors.brand),
                  SizedBox(width: 10),
                  Text('Şifre Değiştir', style: AppTextStyles.title),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yeni şifrenizi girin. Şifreniz en az 6 karakter olmalıdır.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        labelText: 'Yeni Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscured ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              isObscured = !isObscured;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        labelText: 'Yeni Şifre (Tekrar)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        dialogError!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final pass = newPasswordController.text.trim();
                          final confirmPass = confirmPasswordController.text.trim();

                          if (pass.length < 6) {
                            setDialogState(() {
                              dialogError = 'Şifre en az 6 karakter olmalıdır.';
                            });
                            return;
                          }
                          if (pass != confirmPass) {
                            setDialogState(() {
                              dialogError = 'Şifreler birbiriyle eşleşmiyor.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          try {
                            await supabase.auth.updateUser(
                              UserAttributes(password: pass),
                            );
                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Şifreniz başarıyla güncellendi.'),
                                  backgroundColor: AppColors.brand,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = 'Şifre güncellenemedi: ${e.toString()}';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Güncelle', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteAccountConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text('Hesabı Sil', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesabınızı silmek istediğinize emin misiniz?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bu işlem geri alınamaz. Tüm kayıtlı alerji, diyet tercihleriniz ve geçmiş verileriniz kalıcı olarak silinecektir.',
                style: AppTextStyles.body,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Evet, Hesabımı Sil',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    if (!mounted) return;
    // İkinci ve son onay — yanlışlıkla tek dokunuşla hesap silinmesin.
    final finalConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Son kez soruyoruz',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bu son onaydır. Onaylarsan hesabın ve tüm verilerin kalıcı olarak silinecek.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Evet, Eminim — Sil',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (finalConfirmed != true || !mounted) return;

    try {
      await ref.read(profileRepositoryProvider).deleteAccount();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesabınız silindi.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      await _signOut();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hesap silme işlemi gerçekleştirilemedi.')),
        );
      }
    }
  }

  Widget _buildUserCard() {
    final rawEmail = supabase.auth.currentUser?.email;
    final maskedEmail = EmailMasker.maskEmail(rawEmail);
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
                  maskedEmail,
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
  Widget build(BuildContext context) {
    final isPremium = ref.watch(homeViewModelProvider).isPremium;
    final country = ref.watch(profileViewModelProvider).country;
    final rawEmail = supabase.auth.currentUser?.email;
    final maskedEmail = EmailMasker.maskEmail(rawEmail);

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
              icon: Icons.email_outlined,
              label: 'Kayıtlı E-posta',
              subtitle: maskedEmail,
              onTap: null,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.person_outline_rounded,
              label: 'Profil Bilgilerini Düzenle',
              onTap: _navigateToProfile,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.lock_reset_rounded,
              label: 'Şifre Değiştir',
              onTap: () => _showChangePasswordDialog(context),
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.public_rounded,
              label: 'Ülke Seçimi',
              subtitle: (country != null && country.isNotEmpty) ? country : 'Seçilmedi',
              onTap: _editCountry,
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
            const _SettingsSectionHeader(title: 'GÖRÜNÜM'),
            const SizedBox(height: 8),
            _SettingsSwitchRow(
              icon: Icons.dark_mode_outlined,
              label: 'Koyu Tema (Dark Theme)',
              value: ref.watch(themeViewModelProvider).isDarkMode,
              onChanged: (bool val) {
                ref.read(themeViewModelProvider).toggleTheme(val);
              },
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
              onTap: _signOut,
            ),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.delete_forever_rounded,
              label: 'Hesabı Sil',
              isDestructive: true,
              onTap: () => _showDeleteAccountConfirmationDialog(context),
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
    this.onTap,
    this.iconColor,
    this.subtitle,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

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
              if (onTap != null)
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

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.cardTheme.color ?? AppColors.surface;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: theme.colorScheme.onSurface),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.title.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
            Switch(
              value: value,
              activeColor: AppColors.brand,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
