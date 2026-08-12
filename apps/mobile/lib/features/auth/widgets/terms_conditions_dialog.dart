import 'package:flutter/material.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Kullanım Şartları ve Gizlilik Sözleşmesi detaylarını gösteren diyalog penceresi.
class TermsConditionsDialog extends StatelessWidget {
  const TermsConditionsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const TermsConditionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AkilliSepetColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AkilliSepetColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.termsLink,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AkilliSepetColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.termsIntro,
                style: const TextStyle(
                  fontSize: 13,
                  color: AkilliSepetColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),

              _TermsSection(
                title: l10n.termsSection1Title,
                body: l10n.termsSection1Body,
              ),
              _TermsSection(
                title: l10n.termsSection2Title,
                body: l10n.termsSection2Body,
              ),
              _TermsSection(
                title: l10n.termsSection3Title,
                body: l10n.termsSection3Body,
              ),
              _TermsSection(
                title: l10n.termsSection4Title,
                body: l10n.termsSection4Body,
              ),
              _TermsSection(
                title: l10n.termsSection5Title,
                body: l10n.termsSection5Body,
              ),

              const SizedBox(height: 8),
              Text(
                l10n.termsLastUpdated,
                style: const TextStyle(
                  fontSize: 11,
                  color: AkilliSepetColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AkilliSepetColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.termsClose,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AkilliSepetColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AkilliSepetColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
