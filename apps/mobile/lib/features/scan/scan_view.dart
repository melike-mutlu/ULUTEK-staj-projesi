import 'package:flutter/material.dart';

/// Tara — alt navigasyonun 2. sekmesi.
/// Figma: "Tarama Ekranı" mockup — mobile_scanner ile kamera görünümü
/// + "barkodu manuel gir" yedek seçeneği.
class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Tarama içeriği:
    // - MobileScanner kamera görünümü + hedef çerçevesi
    // - Kamera izni reddedilirse açıklama ve ayarlara yönlendirme
    // - "Barkodu manuel gir" yedek seçeneği
    // - Okunan barkodu ScanViewModel.onBarcodeScanned'e ver, sonucu
    //   AppRoutes.productDetail'e taşı
    //
    // DİKKAT: Bu ekran hem sekme (IndexedStack içinde, sürekli canlı) hem de
    // ayrı bir route olarak açılabiliyor. Kamerayı sekme pasifken durdurmak
    // gerekir — aksi halde arka planda çalışıp pil yakar. MobileScannerController
    // start/stop'u sekme değişimine ve uygulama yaşam döngüsüne bağlanmalı.
    return Scaffold(
      appBar: AppBar(title: const Text('Tara')),
    );
  }
}
