import 'package:flutter/material.dart';

import '../../../core/theme/akilli_sepet_colors.dart';

/// Premium olmayan kullanıcılar için gösterilen statik reklam yer tutucu kutusu.
/// Gerçek SDK entegre edilene kadar görsel alan olarak hizmet verir.
class AdPlaceholderCard extends StatelessWidget {
  const AdPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AkilliSepetColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: AkilliSepetColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'REKLAM ALANI',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AkilliSepetColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Sponsorlu',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AkilliSepetColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Burada sponsorlu ürün duyuruları veya dinamik reklamlar görüntülenecektir.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AkilliSepetColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ayarlar\'dan Premium\'a geçerek reklamları kaldırabilirsiniz.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AkilliSepetColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
