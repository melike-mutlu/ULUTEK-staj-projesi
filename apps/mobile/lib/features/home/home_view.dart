import 'package:flutter/material.dart';
import '../../core/theme/akilli_sepet_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Hoşgeldiniz Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba,',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AkilliSepetColors.textSecondary,
                            ),
                      ),
                      Text(
                        'Elif',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AkilliSepetColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  // Profil Butonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AkilliSepetColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Tara Butonu (Yeşil Daire)
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/scan');
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AkilliSepetColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AkilliSepetColors.primary.withAlpha(100),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Barkod Simgesi
                        const Icon(
                          Icons.qr_code_2,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tara',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Alt Açıklama
              Center(
                child: Text(
                  'Bir ürünün barkodunu okut, içeriğini ve\nsana uygunluğunu öğren',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AkilliSepetColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 40),
              // Son Taramaların Başlığı
              Text(
                'Son Taramaların',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AkilliSepetColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              // Son Taramalar Listesi
              _buildRecentScanCard(
                context,
                title: 'Eti Cin Findıklı Gofret',
                note: 'Uyarı — alerjen çakışması',
                noteColor: AkilliSepetColors.warning,
                backgroundColor: const Color(0xFFFFEBEE),
                time: '2 dk önce',
              ),
              const SizedBox(height: 12),
              _buildRecentScanCard(
                context,
                title: 'Ülker Bitter Çikolata %70',
                note: 'Dikkat — diyet notu',
                noteColor: AkilliSepetColors.caution,
                backgroundColor: const Color(0xFFFFFDE7),
                time: 'dün',
              ),
              const SizedBox(height: 12),
              _buildRecentScanCard(
                context,
                title: 'Bağdat Yulaf Ezmesi Sade',
                note: 'Uygun',
                noteColor: AkilliSepetColors.success,
                backgroundColor: const Color(0xFFE8F5E9),
                time: '3 gün önce',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AkilliSepetColors.divider)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AkilliSepetColors.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.barcode_reader),
              label: 'Tara',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Geçmiş',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: 0,
          fixedColor: AkilliSepetColors.primary,
          onTap: (index) {
            // Navigation implementation
          },
        ),
      ),
    );
  }

  Widget _buildRecentScanCard(
    BuildContext context, {
    required String title,
    required String note,
    required Color noteColor,
    required Color backgroundColor,
    required String time,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Renkli Nokta
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: noteColor, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          // İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AkilliSepetColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: noteColor),
                    const SizedBox(width: 6),
                    Text(
                      note,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: noteColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Zaman
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AkilliSepetColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
