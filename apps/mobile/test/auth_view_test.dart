import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/features/auth/auth_view.dart';
import 'package:akilli_sepet/features/auth/auth_viewmodel.dart';

void main() {
  test('AuthViewModel signInAsGuest sets loading and returns true', () async {
    final viewModel = AuthViewModel();
    final result = await viewModel.signInAsGuest();
    expect(result, isTrue);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, isNull);
  });

  testWidgets('AuthView renders Misafir Olarak Devam Et button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
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
