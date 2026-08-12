import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/utils/relative_date.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/user_avatar_circle.dart';
import 'widgets/ad_placeholder_card.dart';
import 'widgets/recent_scan_card.dart';
import '../search/search_viewmodel.dart';
import '../search/widgets/search_bar_field.dart';
import '../search/widgets/search_result_tile.dart';
import '../shell/shell_viewmodel.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider).loadDashboardData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Opens a search hit's product detail by barcode, then clears the search so
  /// the dashboard is back when the user returns.
  void _openSearchResult(String barcode) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    ref.read(searchViewModelProvider).clear();
    _openProductDetail(barcode);
  }

  // --- YENİ: TÜM GEÇMİŞİ GÖSTEREN AŞAĞIDAN KAYARAK AÇILAN PANEL ---
  void _showAllHistoryBottomSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Butona basıldığı an veritabanından 50'lik tüm listeyi çekmeye başlıyoruz
    ref.read(homeViewModelProvider).loadFullHistory();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Panelin ekranın büyük kısmını kaplamasına izin verir
      backgroundColor: Colors.transparent, // Köşelerin yuvarlak olabilmesi için
      builder: (sheetContext) {
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
                  final historyVm = ref.watch(homeViewModelProvider);

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
                          l10n.allMyScans,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AkilliSepetColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Liste Kısmı
                        Expanded(
                          child: historyVm.isLoadingFullHistory
                              ? const Center(child: CircularProgressIndicator(color: AkilliSepetColors.primary))
                              : historyVm.fullHistory.isEmpty
                                  ? Center(child: Text(l10n.historyNotFound, style: const TextStyle(color: Colors.grey)))
                                  : ListView.builder(
                                      controller: scrollController, // Parmağınla paneli kaydırmanı sağlar
                                      itemCount: historyVm.fullHistory.length,
                                      itemBuilder: (context, index) {
                                        final entry = historyVm.fullHistory[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: RecentScanCard(
                                            title: entry.productName ?? l10n.barcodeLabel(entry.barcode),
                                            note: l10n.contentAnalysis,
                                            noteColor: AkilliSepetColors.success,
                                            backgroundColor: const Color(0xFFE8F5E9),
                                            time: formatScanDate(entry.scannedAt),
                                            onTap: () {
                                              // Close the sheet first so detail opens on the page below.
                                              Navigator.pop(sheetContext);
                                              _openProductDetail(entry.barcode);
                                            },
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
    final mediaPadding = MediaQuery.of(context).padding;
    final bottomInset = mediaPadding.bottom;
    // Keep the greeting and avatar clear of the status bar / notch, like the
    // other screens do with SafeArea. Device driven, not a fixed offset.
    final topInset = mediaPadding.top;
    final viewModel = ref.watch(homeViewModelProvider);
    final search = ref.watch(searchViewModelProvider);
    final l10n = AppLocalizations.of(context);
    final isSearching = search.status != SearchStatus.idle;

    return Scaffold(
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AkilliSepetColors.primary))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16 + topInset, 16, 16 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. KULLANICI SELAMLAMA VE PROFİL ---
                    Row(
                      key: const Key('screenHeaderRow'),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeGreeting,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AkilliSepetColors.textSecondary,
                                  ),
                            ),
                            Text(
                              viewModel.displayName.isNotEmpty ? viewModel.displayName : l10n.userFallback,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AkilliSepetColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        UserAvatarCircle(
                          name: viewModel.displayName,
                          avatarUrl: viewModel.avatarUrl,
                          onTap: () => ref
                              .read(shellViewModelProvider)
                              .selectTab(ShellTab.profile),
                        ),
                      ],
                    ),
                    
                    // --- ÜRÜN ARAMA ÇUBUĞU ---
                    const SizedBox(height: 24),
                    SearchBarField(
                      controller: _searchController,
                      onChanged: (value) => search.onQueryChanged(value),
                      onClear: search.clear,
                    ),
                    const SizedBox(height: 24),

                    // While searching, the results replace the dashboard so the
                    // page stays focused; clearing the query brings it back.
                    if (isSearching)
                      _buildSearchResults(search, l10n)
                    else ...[
                    // --- 2. TARA BUTONU ---
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/scan').then((_) {
                            ref.read(homeViewModelProvider).loadDashboardData();
                            ref.read(homeViewModelProvider).loadFullHistory();
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
                                l10n.scanButton,
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
                        l10n.scanTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AkilliSepetColors.textSecondary,
                            ),
                      ),
                    ),
                    
                    if (!viewModel.isPremium) ...<Widget>[
                      const SizedBox(height: 24),
                      const AdPlaceholderCard(),
                    ],

                    const SizedBox(height: 24),

                    // --- 3. SON TARAMALAR LİSTESİ ---
                    Text(
                      l10n.recentScansTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AkilliSepetColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (viewModel.recentScans.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            l10n.noScansYet,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    else ...[
                      // Sadece son 3 taramayı çiz
                      ...viewModel.recentScans.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: RecentScanCard(
                            title: entry.productName ?? l10n.barcodeLabel(entry.barcode),
                            note: l10n.contentAnalysis,
                            noteColor: AkilliSepetColors.success,
                            backgroundColor: const Color(0xFFE8F5E9),
                            time: formatScanDate(entry.scannedAt),
                            onTap: () => _openProductDetail(entry.barcode),
                          ),
                        );
                      }),
                      
                      // --- YENİ EKLENEN: TÜMÜNÜ GÖR BUTONU ---
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showAllHistoryBottomSheet(context, ref),
                          icon: const Icon(Icons.keyboard_arrow_down, color: AkilliSepetColors.primary),
                          label: Text(
                            l10n.seeAllHistory,
                            style: const TextStyle(
                              color: AkilliSepetColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    ], // end of dashboard (shown when not searching)
                  ],
                ),
              ),
            ),
    );
  }

  /// Search states below the bar: spinner, results, empty and error. Rendered
  /// inline so the whole page scrolls as one.
  Widget _buildSearchResults(SearchViewModel search, AppLocalizations l10n) {
    switch (search.status) {
      case SearchStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: 32),
          child: Center(
            child: CircularProgressIndicator(color: AkilliSepetColors.primary),
          ),
        );
      case SearchStatus.empty:
        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Center(
            child: Text(
              l10n.searchNoResults,
              style: const TextStyle(color: AkilliSepetColors.textSecondary, fontSize: 16),
            ),
          ),
        );
      case SearchStatus.error:
        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Center(
            child: Text(
              l10n.searchError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AkilliSepetColors.textSecondary, fontSize: 16),
            ),
          ),
        );
      case SearchStatus.results:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final result in search.results)
              SearchResultTile(
                result: result,
                onTap: () => _openSearchResult(result.barcode),
              ),
          ],
        );
      case SearchStatus.idle:
        return const SizedBox.shrink();
    }
  }

  void _openProductDetail(String barcode) {
    Navigator.pushNamed(context, AppRoutes.productDetail, arguments: barcode);
  }

}
