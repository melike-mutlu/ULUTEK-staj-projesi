import 'package:akilli_sepet/data/repositories/profile_repository.dart';
import 'package:akilli_sepet/features/profile/profile_view.dart';
import 'package:akilli_sepet/shared/services/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopImagePickerService implements ImagePickerService {
  @override
  Future<PickedImage?> pickFromGallery() async => null;
}

Widget _profileUnderTest(ProfileRepository repository) {
  return ProviderScope(
    overrides: <Override>[
      profileRepositoryProvider.overrideWithValue(repository),
      imagePickerServiceProvider.overrideWithValue(_NoopImagePickerService()),
    ],
    child: const MaterialApp(home: ProfileView()),
  );
}

void main() {
  testWidgets('ad kutusu kapaninca controller erken dispose edilmiyor',
      (tester) async {
    final repository = InMemoryProfileRepository();
    await tester.pumpWidget(_profileUnderTest(repository));
    await tester.pumpAndSettle();

    // Baslikta ad satirina dokun -> kutu acilir.
    await tester.tap(find.text('mock'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Melike');
    await tester.tap(find.text('Tamam'));

    // Kapanis animasyonu SIRASINDA TextField hala bagli; controller burada
    // dispose edilirse kare kare pump ederken patlar.
    await tester.pumpAndSettle();

    expect(find.text('Melike'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ada dokunup vazgecince taslak degismiyor', (tester) async {
    final repository = InMemoryProfileRepository();
    await tester.pumpWidget(_profileUnderTest(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('mock'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Yazildi');
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(find.text('Yazildi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
