import '../../l10n/app_localizations.dart';

/// Localizes the app's fixed fallback explanation lines.
///
/// The verdict summary/message is usually AI-generated prose (localized by the
/// backend), but when the model is unavailable both the `explain-product` edge
/// function and the client's deterministic path emit a small set of fixed
/// Turkish sentinels. Those are mirrored here so the UI can show them in the
/// active language. Any other (genuine AI) text is returned unchanged.
///
/// Keep the Turkish keys in sync with:
///  - supabase/functions/explain-product/index.ts (`callLlmPlaceholder`)
///  - product_detail_viewmodel.dart (`_deterministicExplanation`,
///    `_applyPendingProductRule`)
String localizeExplanationFallback(AppLocalizations l10n, String text) {
  switch (text.trim()) {
    case 'Ürün açıklaması şu an oluşturulamadı.':
      return l10n.fallbackNoExplanationSummary;
    case 'Açıklama şu an oluşturulamadı; ürün bilgileri aşağıda.':
      return l10n.fallbackNoExplanationDetail;
    case 'Bu üründe profilinle çakışan içerik var; ayrıntılar aşağıda.':
      return l10n.fallbackProfileConflict;
    case 'Bu üründe riskli içerik veya alerjen tespit edildi.':
      return l10n.fallbackRiskDetected;
    case 'Bu ürün profilinize uygundur.':
      return l10n.fallbackSuitable;
    case 'Bu ürün topluluk tarafından eklendi, henüz doğrulanmadı. '
          'Bilgiler resmi onay beklemektedir.':
      return l10n.fallbackPendingNotice;
    default:
      return text;
  }
}
