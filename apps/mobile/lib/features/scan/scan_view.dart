import 'package:flutter/material.dart';

/// Figma: "Tarama Ekranı" mockup — mobile_scanner ile kamera görünümü
/// + "barkodu manuel gir" yedek seçeneği.
class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: MobileScanner widget'ı + manuel giriş yedeği.
    // Barkod okunduğunda ScanViewModel.onBarcodeScanned(barcode) çağrılır,
    // sonuç ile /product-detail'e yönlendirilir.
    return const Scaffold(
      body: Center(child: Text('Tarama Ekranı')),
    );
  }
}
