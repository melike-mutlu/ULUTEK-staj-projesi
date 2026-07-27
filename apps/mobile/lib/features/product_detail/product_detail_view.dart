import 'package:flutter/material.dart';
import '../../app.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Şimdilik ürün bulunamadı durumunu göster
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tarama Sonucu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hata Simgesi
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Color(0xFFFFB84D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Barkod Bilgisi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Barkod: 8 690 504 112 233',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Başlık
                  Text(
                    'Bu ürünü veritabanımızda\nbulamadık',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AkilliSepetColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Açıklama
                  Text(
                    'Yanış bilgi vermektense dürüst olmayı tercih ederiz. Barkodu elle girebilir ya da ürünü bize bildirerek yardımcı olabilirsin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AkilliSepetColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            // Butonlar
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showManualBarcodeDialog(context);
                  },
                  child: const Text('Barkodu Elle Gir'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Ürünü bildir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ürün bildirimi gönderildi')),
                    );
                  },
                  child: const Text('Ürünü Bize Bildir'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  child: const Text('Ana Sayfaya Dön'),
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
              Navigator.pop(context);
              // Arama işlemi yapılır
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}
