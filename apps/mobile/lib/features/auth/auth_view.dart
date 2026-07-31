import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = true;

  Future<void> _submit() async {
    final vm = ref.read(authViewModelProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = _isSignUpMode
        ? await vm.signUp(email, password)
        : await vm.signIn(email, password);

    if (success && mounted) {
      // Onboarding'e mi shell'e mi gidileceğine StartupGate karar verir:
      // profil satırı olan kullanıcı onboarding'i tekrar görmemeli.
      Navigator.of(context).pushReplacementNamed(AppRoutes.startup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider);

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
            if (vm.errorMessage != null)
              Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.isLoading ? null : _submit,
              child: vm.isLoading
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