import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/profile_options.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/inline_error_row.dart';
import '../../shared/widgets/primary_button.dart';
import 'profile_viewmodel.dart';
import 'widgets/name_edit_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_section_card.dart';

/// Profil — alt navigasyonun 4. sekmesi.
/// Onboarding'de verilen alerji/diyet/sağlık seçimlerini düzenleme ekranı.
///
/// Chip selections are edited locally and written to Supabase in one go with
/// the "Kaydet" button. Name and photo do not go through it — each saves as
/// soon as it is changed.
class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  static const double _horizontalPadding = 16;
  static const double _contentMaxWidth = 520;
  static const double _sectionGap = 16;

  /// Breathing room under the save button, added on top of the bar inset.
  static const double _bottomPadding = 24;

  /// Long enough for real names, short enough to keep the header on one line.
  static const int _nameMaxLength = 50;

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

  /// Adı düzenleme kutusu. Çiplerin aksine anında kaydeder — alttaki "Kaydet"
  /// butonunu beklemez.
  Future<void> _editName(ProfileViewModel viewModel) async {
    // Kutuda kayıtlı ad durur — e-posta'dan türetilen yedek isim değil, yoksa
    // kullanıcı hiç yazmadığı bir adı kaydetmiş olurdu.
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => NameEditDialog(
        initialName: viewModel.displayNameDraft,
        maxLength: _nameMaxLength,
      ),
    );

    // null = vazgeçildi; boş string geçerli bir girdi ("adı kaldır").
    if (result == null) return;

    final saved = await viewModel.saveDisplayName(result);
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adın güncellendi.')),
    );
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
      // bottom: false — letting SafeArea eat the bottom inset ends the scroll
      // viewport above the floating bar, clipping content early. The inset goes
      // to the scroll view's padding instead, so content flows behind the bar
      // while the last item stays reachable above it.
      body: SafeArea(bottom: false, child: _buildBody(viewModel)),
    );
  }

  Widget _buildBody(ProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.loadFailed) {
      return ErrorStateView(
        message: viewModel.errorMessage ?? 'Profil yüklenemedi.',
        onRetry: viewModel.load,
      );
    }
    return _buildForm(viewModel);
  }

  Widget _buildForm(ProfileViewModel viewModel) {
    // Room for the shell's floating bar comes from MediaQuery (see
    // shell_view.dart `_TabContentInset`); opened standalone this is just the
    // system safe area.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _horizontalPadding,
        8,
        _horizontalPadding,
        _bottomPadding + bottomInset,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ProfileHeader(
                email: viewModel.email,
                name: viewModel.resolvedDisplayName,
                avatarUrl: viewModel.avatarUrl,
                isUploadingPhoto: viewModel.isUploadingAvatar,
                onEditName:
                    viewModel.isSavingName ? null : () => _editName(viewModel),
                onEditPhoto: viewModel.pickAndUploadAvatar,
              ),
              const SizedBox(height: 24),
              for (final field in OnboardingField.values) ...<Widget>[
                ProfileSectionCard(
                  title: profileSectionTitles[field]!,
                  options: viewModel.optionsFor(field),
                  selected: viewModel.selectionsFor(field),
                  onToggle: (String option) =>
                      viewModel.toggleOption(field, option),
                  onAddCustom: (String option) =>
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
                isCompact: true,
                alignment: Alignment.centerRight,
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
