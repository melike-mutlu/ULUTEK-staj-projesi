

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart'; // Renkler için eklendi

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Ekran açıldığında kullanıcı bilgisini yüklüyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. KULLANICI SELAMLAMA ---
              Text(
                'Merhaba, ${viewModel.userName} 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bugün ne yediğini öğrenmek ister misin?',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const Spacer(),

              // --- 2. SENİN ORİJİNAL TARA BUTONUN ---
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

              const Spacer(),

              Center(
                child: Text(
                  'Bir ürünün barkodunu okut, içeriğini ve\nsana uygunluğunu öğren',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AkilliSepetColors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







