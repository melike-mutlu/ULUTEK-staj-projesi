import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/widgets/inline_error_row.dart';
import '../startup/startup_destination.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = true;

  /// Keeps the button spinner up while the destination is being resolved, so
  /// no intermediate loading screen is needed.
  bool _isResolvingRoute = false;

  Future<void> _submit() async {
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

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider);
    final isBusy = vm.isLoading || _isResolvingRoute;

    return Scaffold(
      appBar: AppBar(title: Text(_isSignUpMode ? 'Kayıt Ol' : 'Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
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
            if (vm.errorMessage != null)
              Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isBusy ? null : _submit,
              child: isBusy
                  ? const CircularProgressIndicator()
                  : Text(_isSignUpMode ? 'Kayıt Ol' : 'Giriş Yap'),
            ),
            TextButton(
              onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
              child: Text(_isSignUpMode
                  ? 'Zaten hesabın var mı? Giriş yap'
                  : 'Hesabın yok mu? Kayıt ol'),
            ),
          ],
        ),
      ),
    );
  }
}