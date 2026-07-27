import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Tara — alt navigasyonun 2. sekmesi.
/// Figma: "Tarama Ekranı" mockup — mobile_scanner ile kamera görünümü
/// + "barkodu manuel gir" yedek seçeneği.
class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: MobileScanner widget'ı + manuel giriş yedeği.
    // Barkod okunduğunda ScanViewModel.onBarcodeScanned(barcode) çağrılır,
    // sonuç ile AppRoutes.productDetail'e yönlendirilir.
    //
    // DİKKAT: Bu ekran hem sekme (IndexedStack içinde, sürekli canlı) hem de
    // ayrı bir route olarak açılabiliyor. Kamerayı sekme pasifken durdurmak
    // gerekir — aksi halde arka planda çalışıp pil yakar. MobileScannerController
    // start/stop'u sekme değişimine ve uygulama yaşam döngüsüne bağlanmalı.
    return Scaffold(
      appBar: AppBar(title: const Text('Tara')),
      body: const FeaturePlaceholder(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Barkod Tarama',
        description:
            'Kamera ile barkod okuma ekranı. Bu ekranın içeriği henüz yazılmadı.',
        todos: <String>[
          'MobileScanner kamera görünümü + hedef çerçevesi',
          'Kamera izni reddedilirse açıklama ve ayarlara yönlendirme',
          '"Barkodu manuel gir" yedek seçeneği',
          'Sekme pasifken / uygulama arka plandayken kamerayı durdur',
          'Okunan barkodu ScanViewModel.onBarcodeScanned\'e ver, sonucu '
              'AppRoutes.productDetail\'e taşı',
        ],
      ),
    );
  }
}
