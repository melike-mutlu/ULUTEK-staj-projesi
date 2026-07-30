import 'package:flutter/material.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';

/// Geçmiş sekmesi (`features/home`) — alt navigasyonun 3. sekmesi (Son Taranan Ürünler).
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Geçmiş Taramalarım',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tarama geçmişi temizlendi')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtreleme Çipleri
              Row(
                children: [
                  _buildFilterChip('Tümü (18)', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🟢 Uygun (12)', 'ok'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🟡 Dikkat (4)', 'caution'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🔴 Riskli (2)', 'warning'),
                ],
              ),
              const SizedBox(height: 20),

              // Liste Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Son İnceledikleriniz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Bugün',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tarama Kartları
              if (_selectedFilter == 'all' || _selectedFilter == 'warning') ...[
                _buildHistoryCard(
                  context,
                  barcode: '8690504041502',
                  title: 'Ülker Çikolatalı Gofret',
                  brand: 'Ülker',
                  statusText: '🔴 Riskli — Gluten ve Süt Alerjisi!',
                  statusColor: AppColors.warning,
                  bgColor: AppColors.warningSoft,
                  time: '14:25',
                ),
                const SizedBox(height: 12),
              ],

              if (_selectedFilter == 'all' || _selectedFilter == 'caution') ...[
                _buildHistoryCard(
                  context,
                  barcode: '8690504112233',
                  title: 'Sütaş Süzme Yoğurt 500g',
                  brand: 'Sütaş',
                  statusText: '🟡 Dikkat — Laktoz Hassasiyeti',
                  statusColor: AppColors.caution,
                  bgColor: AppColors.cautionSoft,
                  time: '11:10',
                ),
                const SizedBox(height: 12),
              ],

              if (_selectedFilter == 'all' || _selectedFilter == 'ok') ...[
                _buildHistoryCard(
                  context,
                  barcode: '8681234567890',
                  title: 'Zuber Fındık & Kakao Bar',
                  brand: 'Zuber',
                  statusText: '🟢 Sizin İçin Tam Uygun',
                  statusColor: AppColors.ok,
                  bgColor: AppColors.okSoft,
                  time: 'Dün',
                ),
                const SizedBox(height: 12),
                _buildHistoryCard(
                  context,
                  barcode: '8690000111222',
                  title: 'Organik Glutensiz Yulaf Ezmesi 400g',
                  brand: 'Bağdat',
                  statusText: '🟢 Sizin İçin Tam Uygun',
                  statusColor: AppColors.ok,
                  bgColor: AppColors.okSoft,
                  time: '3 gün önce',
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brand : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String barcode,
    required String title,
    required String brand,
    required String statusText,
    required Color statusColor,
    required Color bgColor,
    required String time,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.productDetail, arguments: barcode);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Icon(Icons.qr_code_2_rounded, color: statusColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        brand,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
