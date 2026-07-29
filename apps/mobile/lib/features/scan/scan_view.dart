import 'package:flutter/material.dart';
import '../../core/theme/akilli_sepet_colors.dart';

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              // Flaş açma işlemi
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kamera Placeholder
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kamera Görünümü Çerçevesi
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AkilliSepetColors.primary,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Köşe Simgeleri
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                  left: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                  right: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                  left: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                  right: BorderSide(
                                    color: AkilliSepetColors.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Tarama Çizgisi
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 200,
                                height: 2,
                                color: Colors.amber,
                                margin: const EdgeInsets.only(top: 140),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Açıklama Metni
                    Text(
                      'Barkodu cerçeve içine hizala,\notomatik olarak okunacak',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            // Butonlar
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barkodu Elle Gir Butonu
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Elle giriş diyaloğu
                    _showManualBarcodeDialog(context);
                  },
                  label: const Text('Barkodu Elle Gir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManualBarcodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barkodu Girin'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Örn: 8690504112233',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Barkod işleme
              Navigator.pop(context);
              Navigator.pushNamed(context, '/product-detail');
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}
