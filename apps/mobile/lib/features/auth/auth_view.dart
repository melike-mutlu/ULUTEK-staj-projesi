import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../data/repositories/profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/inline_error_row.dart';
import '../startup/startup_destination.dart';

import 'auth_error.dart';
import 'widgets/terms_conditions_dialog.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = true;
  bool _acceptedTerms = false;

  /// Keeps the button spinner up while the destination is being resolved, so
  /// no intermediate loading screen is needed.
  bool _isResolvingRoute = false;

  /// Kayıt modundayken kullanım şartları onaylanmadan hiçbir hesap yöntemiyle
  /// (e-posta, Google, ...) devam edilemez. Onaylanmadıysa uyarı gösterip
  /// `false` döner.
  bool _hasAcceptedTermsOrWarn() {
    if (_isSignUpMode && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).termsRequiredWarning),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }
    return true;
  }

  /// Maps an [AuthError] to its localized message.
  String _errorText(AppLocalizations l10n, AuthError error) => switch (error) {
        AuthError.signUpFailed => l10n.signUpFailed,
        AuthError.signInFailed => l10n.signInFailed,
        AuthError.guestSignInFailed => l10n.guestSignInFailed,
        AuthError.googleSignInFailed => l10n.googleSignInFailed,
      };

  Future<void> _submit() async {
    if (!_hasAcceptedTermsOrWarn()) return;

    final vm = ref.read(authViewModelProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = _isSignUpMode
        ? await vm.signUp(email, password)
        : await vm.signIn(email, password);

    if (!success || !mounted) return;

    setState(() => _isResolvingRoute = true);
    String route;
    try {
      route = await resolveStartupRoute(ref.read(profileRepositoryProvider));
    } catch (_) {
      // Let the gate surface the failure with its retry action.
      route = AppRoutes.startup;
    }
    if (!mounted) return;

    setState(() => _isResolvingRoute = false);
    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_hasAcceptedTermsOrWarn()) return;
    final vm = ref.read(authViewModelProvider);
    await vm.signInWithGoogle();
    // Web'de veya telefonda Google sayfası açılacağı için anında yönlendirme
    // (routing) yapmıyoruz, OAuth callback'i bekliyoruz. Başarılı ise
    // Supabase auth state değişecek ve uygulama ana ekrana geçecektir.
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isResolvingRoute = true);
    final vm = ref.read(authViewModelProvider);
    await vm.signInAsGuest();

    if (!mounted) return;

    String route;
    try {
      route = await resolveStartupRoute(ref.read(profileRepositoryProvider));
      if (route == AppRoutes.auth) {
        route = AppRoutes.onboarding;
      }
    } catch (_) {
      route = AppRoutes.onboarding;
    }

    if (!mounted) return;
    setState(() => _isResolvingRoute = false);
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider);
    final l10n = AppLocalizations.of(context);
    final isBusy = vm.isLoading || _isResolvingRoute;

    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        title: Text(
          _isSignUpMode ? l10n.signUp : l10n.signIn,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AkilliSepetColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_basket_rounded,
                  size: 44,
                  color: AkilliSepetColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.authWelcome,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AkilliSepetColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.authTagline,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AkilliSepetColors.textSecondary),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
            ),
            if (_isSignUpMode) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: AkilliSepetColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptedTerms = !_acceptedTerms;
                        });
                      },
                      child: Wrap(
                        children: [
                          Text(
                            l10n.termsLink,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AkilliSepetColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          InkWell(
                            onTap: () => TermsConditionsDialog.show(context),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                                color: AkilliSepetColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            l10n.termsAcceptSuffix,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AkilliSepetColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (vm.emailAlreadyRegistered) ...[
              InlineErrorRow(
                message: l10n.emailAlreadyRegistered,
                icon: Icons.person_outline_rounded,
                actionLabel: l10n.signIn,
                // Switches to sign-in with the typed email kept.
                onRetry: () {
                  vm.clearEmailAlreadyRegisteredNotice();
                  setState(() => _isSignUpMode = false);
                },
                onDismiss: vm.clearEmailAlreadyRegisteredNotice,
              ),
              const SizedBox(height: 8),
            ],
            if (vm.needsEmailConfirmation) ...[
              InlineErrorRow(
                message: l10n.emailConfirmationNotice,
                icon: Icons.mark_email_unread_outlined,
                onDismiss: vm.clearEmailConfirmationNotice,
              ),
              const SizedBox(height: 8),
            ],
            if (vm.error != null) ...[
              Text(
                _errorText(l10n, vm.error!),
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isBusy ? null : _submit,
                child: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isSignUpMode ? l10n.signUp : l10n.signIn),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
              child: Text(
                _isSignUpMode ? l10n.toggleToSignIn : l10n.toggleToSignUp,
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    l10n.orSeparator,
                    style: const TextStyle(color: AkilliSepetColors.textSecondary, fontSize: 13),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            // Google ile Giriş Butonu
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: vm.isLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/images/google_logo.webp',
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  l10n.googleSignIn,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Misafir Girişi Butonu
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _continueAsGuest,
                icon: const Icon(Icons.person_outline_rounded),
                label: Text(l10n.continueAsGuest),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: AkilliSepetColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}