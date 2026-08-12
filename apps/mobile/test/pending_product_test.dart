import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/data/repositories/pending_product_repository.dart';
import 'package:akilli_sepet/features/pending_product/pending_product_error.dart';
import 'package:akilli_sepet/features/pending_product/pending_product_view.dart';
import 'package:akilli_sepet/features/pending_product/pending_product_viewmodel.dart';
import 'package:akilli_sepet/l10n/app_localizations.dart';

class MockPendingProductRepository extends PendingProductRepository {
  bool shouldSucceed = true;

  @override
  Future<PendingProductResult> submitPendingProduct({
    required String barcode,
    String? productName,
    String? ingredientsText,
    dynamic imageFront,
    dynamic imageIngredients,
    dynamic imageNutrition,
  }) async {
    if (shouldSucceed) {
      return const PendingProductResult(isSuccess: true, data: {'status': 'success'});
    } else {
      return const PendingProductResult(isSuccess: false, errorMessage: 'Test submission failed');
    }
  }
}

void main() {
  test('PendingProductViewModel submit validates empty barcode', () async {
    final mockRepo = MockPendingProductRepository();
    final viewModel = PendingProductViewModel(mockRepo);

    final success = await viewModel.submit();

    expect(success, isFalse);
    expect(viewModel.error, PendingProductError.invalidBarcode);
  });

  test('PendingProductViewModel submit calls repository successfully', () async {
    final mockRepo = MockPendingProductRepository();
    final viewModel = PendingProductViewModel(mockRepo, initialBarcode: '8690504112233');
    viewModel.setProductName('Test Ürün');

    final success = await viewModel.submit();

    expect(success, isTrue);
    expect(viewModel.isSuccess, isTrue);
    expect(viewModel.error, isNull);
  });

  testWidgets('PendingProductView renders title and form fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PendingProductView(barcode: '8690504112233'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ürün Bulunamadı — Bildir'), findsOneWidget);
    expect(find.text('8690504112233'), findsOneWidget);
    expect(find.text('Ürün Bilgileri'), findsOneWidget);
    expect(find.text('Ön Yüz'), findsOneWidget);
    expect(find.text('İçindekiler'), findsOneWidget);
    expect(find.text('Besin Değeri'), findsOneWidget);
    expect(find.text('Ürünü Bildir'), findsOneWidget);
  });
}
