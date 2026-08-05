import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';

/// Figma: "Tarama Ekranı" mockup — kamera görünümü + barkod çerçevesi.
///
/// Kamera/okuma mantığı feature/barkod_okuma PR'ından, tasarım feature/menus
/// PR'ından geliyor. feature/api_baglantisi'nin yaptığı gibi Open Food
/// Facts'i doğrudan istemciden çağırmıyoruz — okunan barkod
/// ScanViewModel.onBarcodeScanned üzerinden bizim fetch-product Edge
/// Function'ımıza gidiyor (bkz. docs/architecture.md, kural motoru orada
/// çalışıyor).
class ScanView extends ConsumerStatefulWidget {
  const ScanView({super.key});

  @override
  ConsumerState<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView> {
  /// Çerçevenin tasarımdaki boyutu; daha dar ekranlarda bunun altına iner.
  static const double _maxFrameSize = 280;

  /// Butonla alt bar arasındaki boşluk.
  static const double _bottomGap = 5;

  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8],
  );

  // Sonuç ekranına giderken aynı barkodu tekrar tekrar işlememek için.
  bool _isHandlingBarcode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String barcode) async {
    if (_isHandlingBarcode) return;
    _isHandlingBarcode = true;

    try {
      final result =
          await ref.read(scanViewModelProvider).onBarcodeScanned(barcode);

      if (!mounted) return;
      await _controller.stop();
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: result,
      );
    } finally {
      if (mounted) {
        await _controller.start();
        _isHandlingBarcode = false;
      }
    }
  }

  void _showManualBarcodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Barkodu Girin'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Örn: 8690504112233',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final value = controller.text.trim();
              if (value.isNotEmpty) _handleBarcode(value);
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  Widget _cornerBracket({required bool top, required bool left}) {
    return Positioned(
      top: top ? 12 : null,
      bottom: top ? null : 12,
      left: left ? 12 : null,
      right: left ? null : 12,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: AkilliSepetColors.primary, width: 3)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: AkilliSepetColors.primary, width: 3)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: AkilliSepetColors.primary, width: 3)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: AkilliSepetColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inside the shell this already includes the floating bar's height (the
    // Scaffold's `extendBody` adds it); opened standalone it is just the system
    // safe area. Clamped because Padding rejects negative values.
    final bottomPadding = math.max(
      0.0,
      MediaQuery.of(context).padding.bottom + _bottomGap,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F), // Koyu fon
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Barkod Tara',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kamera Görünümü Çerçevesi
                    // Flexible + AspectRatio: kare kalır ama kısa ekranlarda
                    // küçülür; sabit yükseklikte alttaki metni taşırıyordu.
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxFrameSize,
                          maxHeight: _maxFrameSize,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AkilliSepetColors.primary,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  MobileScanner(
                                    controller: _controller,
                                    onDetect: (capture) {
                                      if (_isHandlingBarcode) return;

                                      // Karede birden fazla farklı barkod
                                      // görünüyorsa (örn. rafta yan yana
                                      // duran başka bir ürün, çok parçalı
                                      // bir kutu) hangisinin hedeflendiği
                                      // belirsizdir — yanlış ürün açmaktansa
                                      // bu kareyi atla, kamera akmaya devam
                                      // eder ve kullanıcı hizaladığında tek
                                      // barkodlu bir kare yakalanır.
                                      final values = capture.barcodes
                                          .map((b) => b.rawValue)
                                          .whereType<String>()
                                          .toSet();
                                      if (values.length == 1) {
                                        _handleBarcode(values.first);
                                      }
                                    },
                                  ),
                                  _cornerBracket(top: true, left: true),
                                  _cornerBracket(top: true, left: false),
                                  _cornerBracket(top: false, left: true),
                                  _cornerBracket(top: false, left: false),
                                  // Tarama Çizgisi — çerçeveye göre ortalanır.
                                  Center(
                                    child: FractionallySizedBox(
                                      widthFactor: 0.7,
                                      child: Container(
                                        height: 2,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Barkodu çerçeve içine hizala,\notomatik olarak okunacak',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showManualBarcodeDialog(context),
                  label: const Text('Barkodu Elle Gir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
