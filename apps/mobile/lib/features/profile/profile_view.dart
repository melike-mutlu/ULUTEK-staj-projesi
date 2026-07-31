import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/profile_options.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/inline_error_row.dart';
import '../../shared/widgets/primary_button.dart';
import 'profile_viewmodel.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_section_card.dart';

/// Profil — alt navigasyonun 4. sekmesi.
/// Onboarding'de verilen alerji/diyet/sağlık seçimlerini düzenleme ekranı.
///
/// Selections are edited locally and written to Supabase in one go with the
/// "Kaydet" button — not on every chip tap.
class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  static const double _horizontalPadding = 16;
  static const double _contentMaxWidth = 520;
  static const double _sectionGap = 16;

  /// Cards the user opened with "Tümünü gör".
  final Set<OnboardingField> _expanded = <OnboardingField>{};

  @override
  void initState() {
    super.initState();
    // The shell keeps this tab alive, so load runs once. Deferred to the next
    // frame: load() notifies synchronously and that must not land mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profileViewModelProvider).load();
    });
  }

  Future<void> _save(ProfileViewModel viewModel) async {
    final saved = await viewModel.save();
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profilin güncellendi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text('Profil', style: AppTextStyles.heading2),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textPrimary,
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(viewModel)),
    );
  }

  Widget _buildBody(ProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.loadFailed) {
      return _LoadErrorState(
        message: viewModel.errorMessage ?? 'Profil yüklenemedi.',
        onRetry: viewModel.load,
      );
    }
    return _buildForm(viewModel);
  }

  Widget _buildForm(ProfileViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        8,
        _horizontalPadding,
        24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ProfileHeader(email: viewModel.email),
              const SizedBox(height: 24),
              for (final field in OnboardingField.values) ...<Widget>[
                ProfileSectionCard(
                  title: profileSectionTitles[field]!,
                  options: viewModel.optionsFor(field),
                  selected: viewModel.selectionsFor(field),
                  onToggle: (String option) =>
                      viewModel.toggleOption(field, option),
                  // Diet has no "+": a custom label has no DietPreference
                  // counterpart, so it could not round-trip to the database.
                  onAddCustom: field == OnboardingField.diet
                      ? null
                      : (String option) =>
                          viewModel.addCustomOption(field, option),
                  isExpanded: _expanded.contains(field),
                  onShowAll: () => setState(() => _expanded.add(field)),
                ),
                const SizedBox(height: _sectionGap),
              ],
              if (viewModel.errorMessage != null) ...<Widget>[
                InlineErrorRow(
                  message: viewModel.errorMessage!,
                  onRetry: () => _save(viewModel),
                  onDismiss: viewModel.clearError,
                ),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                label: 'Kaydet',
                isLoading: viewModel.isSaving,
                onPressed: viewModel.hasChanges ? () => _save(viewModel) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen state when the profile could not be read.
class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Tekrar dene', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
