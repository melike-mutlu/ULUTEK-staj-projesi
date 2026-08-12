import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/features/auth/auth_view.dart';
import 'package:akilli_sepet/features/auth/auth_viewmodel.dart';
import 'package:akilli_sepet/l10n/app_localizations.dart';

void main() {
  test('AuthViewModel signInAsGuest surfaces failure when Supabase is unavailable',
      () async {
    // Testte gerçek bir Supabase bağlantısı yok, bu yüzden
    // signInAnonymously() gerçekten başarısız olur — signInAsGuest bu hatayı
    // gizlemeden false dönmeli (bkz. daha önceki "her zaman true dönme"
    // hatası).
    final viewModel = AuthViewModel();
    final result = await viewModel.signInAsGuest();
    expect(result, isFalse);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, isNotNull);
  });

  testWidgets('AuthView renders Misafir Olarak Devam Et button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Misafir Olarak Devam Et'), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
  });
}
