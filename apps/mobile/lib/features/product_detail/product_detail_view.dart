import 'package:flutter/material.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import 'product_detail_viewmodel.dart';
import 'widgets/allergens_card.dart';
import 'widgets/nutriments_card.dart';
import 'widgets/product_header_card.dart';
import 'widgets/warning_banner.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late final ProductDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak mock kurgusu ile başlat (Kırmızı / Warning senaryosu)
    _viewModel = ProductDetailViewModel.withMock(mockState: 'warning');
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ürün Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ürün detayı paylaşıldı')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_viewModel.status) {
      case ProductDetailStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AkilliSepetColors.primary),
              SizedBox(height: 16),
              Text(
                'Ürün bilgileri ve AI analizi getiriliyor...',
                style: TextStyle(color: AkilliSepetColors.textSecondary),
              ),
            ],
          ),
        );

      case ProductDetailStatus.notFound:
        return _buildNotFoundState(context);

      case ProductDetailStatus.found:
      case ProductDetailStatus.partial:
      default:
        final product = _viewModel.product;
        final explanation = _viewModel.explanation;

        if (product == null || explanation == null) {
          return _buildNotFoundState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Uygunluk Sonucu (Yeşil / Sarı / Kırmızı Bandı)
              WarningBanner(explanation: explanation),
              const SizedBox(height: 16),

              // 2. Ürün Adı, Marka, Barkod & Nutri-Score Kartı
              ProductHeaderCard(product: product),
              const SizedBox(height: 16),

              // 3. Besin Değerleri Kartı (100g)
              NutrimentsCard(nutriments: product.nutriments),
              const SizedBox(height: 16),

              // 4. Alerjen & İçindekiler Kartı
              AllergensCard(
                product: product,
                ruleEngineResult: _viewModel.ruleEngineResult,
              ),
              const SizedBox(height: 24),

              // Test & Mock Senaryo Seçici (Staj Değerlendirme & Test Kolaylığı İçin)
              _buildMockTesterBar(),
              const SizedBox(height: 20),

              // Ana Butonlar (Sepete Ekle & Ana Sayfa)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Ana Sayfa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} sepete eklendi!'),
                            backgroundColor: AkilliSepetColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Sepete Ekle'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
    }
  }

  Widget _buildMockTesterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report_outlined, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Text(
                'Mock Test Durumları (Demo):',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMockChip('🔴 Kırmızı', () => _viewModel.loadMockState('red')),
              _buildMockChip('🟡 Sarı', () => _viewModel.loadMockState('yellow')),
              _buildMockChip('🟢 Yeşil', () => _viewModel.loadMockState('green')),
              _buildMockChip('❌ Yok', () => _viewModel.setStatusFromFetch('not_found')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Barkod: 8 690 504 112 233',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bu ürünü veritabanımızda\nbulamadık',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AkilliSepetColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Yanlış bilgi vermektense dürüst olmayı tercih ederiz. Barkodu elle girebilir ya da ürünü bize bildirerek yardımcı olabilirsin.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AkilliSepetColors.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _showManualBarcodeDialog(context),
                child: const Text('Barkodu Elle Gir'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ürün bildirimi gönderildi')),
                  );
                },
                child: const Text('Ürünü Bize Bildir'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _viewModel.loadMockState('green');
                },
                child: const Text('Örnek Ürünü Göster (Demo)'),
              ),
            ],
          ),
        ],
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
              _viewModel.loadMockState('green');
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}
