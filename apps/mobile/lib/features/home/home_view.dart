import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/providers.dart'; 

// Dinamik veri çekeceğimiz için ConsumerStatefulWidget yapıyoruz
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  
  @override
  void initState() {
    super.initState();
    // Ekran açıldığında "verileri yükle" emrini veriyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ViewModeldeki verilere ulaşıyoruz
    final viewModel = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AkilliSepetColors.primary))
          : SingleChildScrollView(
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
                              //GERÇEK KULLANICI ADI
                              viewModel.userName.isNotEmpty ? viewModel.userName : 'Kullanıcı',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                          child: Center(
                            child: Text(
                              // İsim "E" yerine kullanıcının baş harfi olsun
                              viewModel.userName.isNotEmpty ? viewModel.userName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // NOT: TARA BUTONU BURADAN KALDIRILDI!
                    
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
                    
                    //GERÇEK TARAMA GEÇMİŞİ LİSTESİ
                    if (viewModel.recentScans.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'Henüz bir ürün taramadınız.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      // Veritabanındaki liste kadar kart oluşturuyoruz
                      ...viewModel.recentScans.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildRecentScanCard(
                            context,
                            title: 'Barkod: ${item['barcode']}',
                            note: 'İçerik Analizi', // İleride uyarı rengine göre değişebilir
                            noteColor: AkilliSepetColors.success,
                            backgroundColor: const Color(0xFFE8F5E9),
                            time: 'Yeni', // İleride saati gösterebiliriz
                          ),
                        );
                      }),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
      //orjinal Bottom Navigation tasarımı
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

  //orjinal kart tasarımı
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


