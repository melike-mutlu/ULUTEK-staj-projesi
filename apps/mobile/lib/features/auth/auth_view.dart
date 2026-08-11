import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/inline_error_row.dart';
import '../startup/startup_destination.dart';

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

  Future<void> _submit() async {
    if (_isSignUpMode && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Devam etmek için lütfen Kullanım Şartları ve Gizlilik Sözleşmesi\'ni kabul edin.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
    final isBusy = vm.isLoading || _isResolvingRoute;

    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        title: Text(
          _isSignUpMode ? 'Kayıt Ol' : 'Giriş Yap',
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
              'Akıllı Sepet\'e Hoş Geldiniz',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AkilliSepetColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kişiselleştirilmiş alışveriş asistanınız',
              textAlign: TextAlign.center,
              style: TextStyle(color: AkilliSepetColors.textSecondary),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
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
                          const Text(
                            'Kullanım Şartları ve Gizlilik Sözleşmesi',
                            style: TextStyle(
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
                          const Text(
                            '\'ni okudum, kabul ediyorum.',
                            style: TextStyle(
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
                message: 'Bu e-posta zaten kayıtlı. Giriş yapın.',
                icon: Icons.person_outline_rounded,
                actionLabel: 'Giriş yap',
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
                message: 'E-postana bir doğrulama bağlantısı gönderdik. '
                    'Bağlantıya tıklayıp hesabını doğrulamadan giriş '
                    'yapamazsın.',
                icon: Icons.mark_email_unread_outlined,
                onDismiss: vm.clearEmailConfirmationNotice,
              ),
              const SizedBox(height: 8),
            ],
            if (vm.errorMessage != null) ...[
              Text(
                vm.errorMessage!,
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
                    : Text(_isSignUpMode ? 'Kayıt Ol' : 'Giriş Yap'),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
              child: Text(_isSignUpMode
                  ? 'Zaten hesabın var mı? Giriş yap'
                  : 'Hesabın yok mu? Kayıt ol'),
            ),

            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'veya',
                    style: TextStyle(color: AkilliSepetColors.textSecondary, fontSize: 13),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            // Misafir Girişi Butonu
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : _continueAsGuest,
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Misafir Olarak Devam Et'),
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