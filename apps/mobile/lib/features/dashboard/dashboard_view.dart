import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/providers.dart';
import '../../shared/widgets/user_avatar_circle.dart';
import '../shell/shell_viewmodel.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider).loadDashboardData();
    });
  }

  // --- YENİ: TÜM GEÇMİŞİ GÖSTEREN AŞAĞIDAN KAYARAK AÇILAN PANEL ---
  void _showAllHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    // Butona basıldığı an veritabanından 50'lik tüm listeyi çekmeye başlıyoruz
    ref.read(homeViewModelProvider).loadHistory();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Panelin ekranın büyük kısmını kaplamasına izin verir
      backgroundColor: Colors.transparent, // Köşelerin yuvarlak olabilmesi için
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white, // Kendi temana göre AkilliSepetColors.surface da yapabilirsin
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6, // İlk açıldığında ekranın %60'ını kaplasın
            minChildSize: 0.4,     // En az %40'a kadar küçülebilmesin
            maxChildSize: 0.9,     // Yukarı kaydırınca ekranın %90'ını kaplasın
            expand: false,
            builder: (context, scrollController) {
              return Consumer(
                builder: (context, ref, child) {
                  // Tüm listenin olduğu beyni anlık dinliyoruz
                  final homeVm = ref.watch(homeViewModelProvider);

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En üstteki gri minik tutma çubuğu (Tasarım detayı)
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Text(
                          'Tüm Taramalarım',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AkilliSepetColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Liste Kısmı
                        Expanded(
                          child: homeVm.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AkilliSepetColors.primary))
                              : homeVm.historyItems.isEmpty
                                  ? const Center(child: Text('Geçmiş bulunamadı.', style: TextStyle(color: Colors.grey)))
                                  : ListView.builder(
                                      controller: scrollController, // Parmağınla paneli kaydırmanı sağlar
                                      itemCount: homeVm.historyItems.length,
                                      itemBuilder: (context, index) {
                                        final item = homeVm.historyItems[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: _buildRecentScanCard(
                                            context,
                                            title: 'Barkod: ${item['barcode']}',
                                            note: 'İçerik Analizi',
                                            noteColor: AkilliSepetColors.success,
                                            backgroundColor: const Color(0xFFE8F5E9),
                                            time: 'Kayıt', // İleride tarih yazdırırız
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final viewModel = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AkilliSepetColors.primary))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // --- 1. KULLANICI SELAMLAMA VE PROFİL ---
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
                              viewModel.displayName.isNotEmpty ? viewModel.displayName : 'Kullanıcı',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AkilliSepetColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        UserAvatarCircle(
                          name: viewModel.displayName,
                          onTap: () => ref
                              .read(shellViewModelProvider)
                              .selectTab(ShellTab.profile),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),

                    // --- 2. TARA BUTONU ---
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/scan').then((_) {
                            ref.read(dashboardViewModelProvider).loadDashboardData();
                            ref.read(homeViewModelProvider).loadHistory(); 
                          });
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
                              const Icon(
                                Icons.qr_code_2,
                                color: Colors.white,
                                size: 64,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tara',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    
                    const SizedBox(height: 20),

                    // --- 3. SON TARAMALAR LİSTESİ ---
                    Text(
                      'Son Taramaların',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AkilliSepetColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
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
                    else ...[
                      // Sadece son 3 taramayı çiz
                      ...viewModel.recentScans.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildRecentScanCard(
                            context,
                            title: 'Barkod: ${item['barcode']}',
                            note: 'İçerik Analizi',
                            noteColor: AkilliSepetColors.success,
                            backgroundColor: const Color(0xFFE8F5E9),
                            time: 'Yeni',
                          ),
                        );
                      }),
                      
                      // --- YENİ EKLENEN: TÜMÜNÜ GÖR BUTONU ---
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showAllHistoryBottomSheet(context, ref),
                          icon: const Icon(Icons.keyboard_arrow_down, color: AkilliSepetColors.primary),
                          label: const Text(
                            'Tüm Geçmişi Gör',
                            style: TextStyle(
                              color: AkilliSepetColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // Orijinal Kart Tasarımı Yardımcı Fonksiyonu
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






