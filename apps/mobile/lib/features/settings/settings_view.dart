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
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    try {
      await supabase.auth.signOut();
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.signOutFailed)),
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
      SnackBar(content: Text(AppLocalizations.of(context).countryUpdated)),
    );
  }

  /// Label for a locale in the picker and the row subtitle. A null locale
  /// follows the device.
  String _languageLabel(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'tr':
        return l10n.languageTurkish;
      case 'en':
        return l10n.languageEnglish;
      default:
        return l10n.languageSystem;
    }
  }

  Future<void> _editLanguage() async {
    final controller = ref.read(localeControllerProvider);
    final l10n = AppLocalizations.of(context);
    // 'system' is the sentinel for "follow the device"; a null result means
    // the sheet was dismissed without a choice.
    final current = controller.locale?.languageCode ?? 'system';

    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(l10n.language, style: AppTextStyles.title),
          children: <Widget>[
            _languageOption(dialogContext, 'system', l10n.languageSystem, current),
            _languageOption(dialogContext, 'tr', l10n.languageTurkish, current),
            _languageOption(dialogContext, 'en', l10n.languageEnglish, current),
          ],
        );
      },
    );

    if (choice == null) return;
    await controller.setLocale(choice == 'system' ? null : Locale(choice));
  }

  Widget _languageOption(
    BuildContext dialogContext,
    String code,
    String label,
    String current,
  ) {
    final isSelected = code == current;
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(dialogContext, code),
      child: Row(
        children: <Widget>[
          Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isSelected ? AppColors.brand : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Future<void> _togglePremium(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(profileRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
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
              !isCurrentlyPremium ? l10n.premiumEnabled : l10n.premiumDisabled,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.premiumUpdateFailed)),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.brand),
              const SizedBox(width: 10),
              Text(l10n.about, style: AppTextStyles.title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aboutVersion,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.aboutBody1, style: AppTextStyles.body),
              const SizedBox(height: 12),
              Text(l10n.aboutBody2, style: AppTextStyles.caption),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.close, style: const TextStyle(color: AppColors.brand)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.brand),
              const SizedBox(width: 10),
              Text(l10n.privacyPolicy, style: AppTextStyles.title),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacyHeading,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.privacyBody1, style: AppTextStyles.body),
                const SizedBox(height: 10),
                Text(l10n.privacyBody2, style: AppTextStyles.caption),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.understood, style: const TextStyle(color: AppColors.brand)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
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
              title: Row(
                children: [
                  const Icon(Icons.lock_reset_rounded, color: AppColors.brand),
                  const SizedBox(width: 10),
                  Text(l10n.changePassword, style: AppTextStyles.title),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.passwordHint,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        labelText: l10n.newPassword,
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
                        labelText: l10n.newPasswordRepeat,
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
                  child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final pass = newPasswordController.text.trim();
                          final confirmPass = confirmPasswordController.text.trim();

                          if (pass.length < 6) {
                            setDialogState(() {
                              dialogError = l10n.passwordTooShort;
                            });
                            return;
                          }
                          if (pass != confirmPass) {
                            setDialogState(() {
                              dialogError = l10n.passwordsDoNotMatch;
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
                                SnackBar(
                                  content: Text(l10n.passwordUpdated),
                                  backgroundColor: AppColors.brand,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = l10n.passwordUpdateFailed(e.toString());
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
                      : Text(l10n.update, style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteAccountConfirmationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 10),
              Text(l10n.deleteAccount, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountConfirmQuestion,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.deleteAccountConfirmBody,
                style: AppTextStyles.body,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.deleteAccountConfirm,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          title: Text(
            l10n.deleteAccountFinalTitle,
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.deleteAccountFinalBody,
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.deleteAccountFinalConfirm,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          SnackBar(
            content: Text(l10n.accountDeleted),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      await _signOut();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountFailed)),
        );
      }
    }
  }

  Widget _buildUserCard(bool isDark) {
    final rawEmail = supabase.auth.currentUser?.email;
    final maskedEmail = EmailMasker.maskEmail(rawEmail);
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark ? AppColors.brand.withOpacity(0.2) : AppColors.brandSoft,
            child: const Icon(Icons.person_rounded, color: AppColors.brand, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maskedEmail,
                  style: AppTextStyles.title.copyWith(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).activeSession,
                  style: AppTextStyles.caption.copyWith(color: secondaryTextColor),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(homeViewModelProvider).isPremium;
    final country = ref.watch(profileViewModelProvider).country;
    final themeVm = ref.watch(themeViewModelProvider);

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final locale = ref.watch(localeControllerProvider).locale;
    final l10n = AppLocalizations.of(context);
    final rawEmail = supabase.auth.currentUser?.email;
    final maskedEmail = EmailMasker.maskEmail(rawEmail);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(l10n.settingsTitle, style: AppTextStyles.heading2.copyWith(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildUserCard(isDark),
                const SizedBox(height: 24),
                _SettingsSectionHeader(title: l10n.settingsSectionAccount),
                const SizedBox(height: 8),
                _SettingsRow(
                  icon: Icons.email_outlined,
                  label: l10n.registeredEmail,
                  subtitle: maskedEmail,
                  onTap: null,
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.editProfileInfo,
                  onTap: _navigateToProfile,
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: Icons.lock_reset_rounded,
                  label: l10n.changePassword,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: Icons.public_rounded,
                  label: l10n.countrySelection,
                  subtitle: (country != null && country.isNotEmpty) ? country : l10n.notSelected,
                  onTap: _editCountry,
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.workspace_premium_outlined,
                  iconColor: isPremium ? const Color(0xFFFFB300) : null,
                  label: isPremium ? l10n.premiumExit : l10n.premiumGo,
                  subtitle: isPremium ? l10n.premiumActive : l10n.premiumTest,
                  onTap: () => _togglePremium(context, ref),
                ),
                const SizedBox(height: 24),
                _SettingsSectionHeader(title: l10n.settingsSectionApp),
                const SizedBox(height: 8),
                _SettingsSwitchRow(
                  icon: Icons.dark_mode_outlined,
                  label: l10n.darkTheme,
                  value: themeVm.isDarkMode,
                  onChanged: (bool value) {
                    ref.read(themeViewModelProvider).toggleTheme(value);
                  },
                ),
                const SizedBox(height: 10),

                _SettingsSwitchRow(
                  icon: Icons.child_care_rounded,
                  label: 'Basit Görünüm Modu',
                  value: ref.watch(simpleModeProvider), // Provider'ı dinliyoruz
                  onChanged: (bool value) {
                    ref.read(simpleModeProvider.notifier).state = value; // Değeri güncelliyoruz
                  },
                ),
                const SizedBox(height: 10),

                _SettingsRow(
                  icon: Icons.language_rounded,
                  label: l10n.language,
                  subtitle: _languageLabel(l10n, locale),
                  onTap: _editLanguage,
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  label: l10n.privacyPolicy,
                  onTap: () => _showPrivacyDialog(context),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  label: l10n.about,
                  subtitle: 'v1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                const SizedBox(height: 24),
                _SettingsSectionHeader(title: l10n.settingsSectionSession),
                const SizedBox(height: 8),
                _SettingsRow(
                  icon: Icons.logout_rounded,
                  label: l10n.signOut,
                  isDestructive: true,
                  onTap: _signOut,
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: l10n.deleteAccount,
                  isDestructive: true,
                  onTap: () => _showDeleteAccountConfirmationDialog(context),
                ),
              ],
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: secondaryTextColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final color = isDestructive ? AppColors.warning : textColor;
    final effectiveIconColor = iconColor ?? color;

    return Material(
      color: surfaceColor,
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
                  style: AppTextStyles.caption.copyWith(color: secondaryTextColor),
                ),
                const SizedBox(width: 8),
              ],
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive ? AppColors.warning : secondaryTextColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: textColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.title.copyWith(color: textColor),
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
