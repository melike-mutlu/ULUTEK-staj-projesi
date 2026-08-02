
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/providers.dart';
import '../../shared/widgets/user_avatar_circle.dart';
import '../shell/shell_viewmodel.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  
  @override
  Widget build(BuildContext context) {
    // Shell'in alt barı için gerekli boşluk hesabı
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Kullanıcı adını göstermek için (geçmiş liste ile işimiz bitti ama isim için Dashboard beyininden bilgiyi alıyoruz)
    final viewModel = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HOŞGELDİNİZ BAŞLIĞI VE PROFİL ---
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
                        viewModel.userName.isNotEmpty ? viewModel.userName : 'Kullanıcı',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AkilliSepetColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  UserAvatarCircle(
                    name: viewModel.userName,
                    onTap: () => ref
                        .read(shellViewModelProvider)
                        .selectTab(ShellTab.profile),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // --- CHATBOT İÇERİĞİ (GEÇİCİ YER TUTUCU) ---
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined, // Chatbot ikonu
                        size: 80,
                        color: AkilliSepetColors.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Akıllı Asistan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AkilliSepetColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sohbet arayüzü buraya eklenecek...',
                        style: TextStyle(
                          color: AkilliSepetColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
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

