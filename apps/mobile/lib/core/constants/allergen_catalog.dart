import '../../l10n/app_localizations.dart';

/// Display name and icon for a canonical allergen key.
///
/// [label] is the Turkish default; [labelKey] is a stable id the UI maps to a
/// localized name via [allergenLabel]. A null [labelKey] means the label came
/// from a raw, unmapped tag and should be shown as-is.
class AllergenInfo {
  const AllergenInfo(this.label, this.asset, {this.labelKey});

  final String label;
  final String asset;
  final String? labelKey;
}

const String _assetDir = 'assets/allergens';

/// Shown when the backend sends a key we have no icon for.
const AllergenInfo _unknownAllergen =
    AllergenInfo('Bilinmeyen alerjen', '$_assetDir/other.png',
        labelKey: 'unknown');

/// Canonical key (the bare Open Food Facts token the rule engine returns)
/// -> label + icon. File names do not follow the keys, so the mapping is
/// explicit. A new allergen = one new entry here.
const Map<String, AllergenInfo> allergenCatalog = <String, AllergenInfo>{
  'gluten': AllergenInfo('Gluten', '$_assetDir/gluten.png', labelKey: 'gluten'),
  'milk': AllergenInfo('Süt / Laktoz', '$_assetDir/milk.png', labelKey: 'milk'),
  'eggs': AllergenInfo('Yumurta', '$_assetDir/egg.png', labelKey: 'eggs'),
  'soybeans': AllergenInfo('Soya', '$_assetDir/soy.png', labelKey: 'soy'),
  'peanuts':
      AllergenInfo('Yer fıstığı', '$_assetDir/peanut.png', labelKey: 'peanuts'),
  'nuts': AllergenInfo(
      'Kabuklu yemişler', '$_assetDir/nuts_and_dried_fruits.png',
      labelKey: 'nuts'),
  'sesame-seeds':
      AllergenInfo('Susam', '$_assetDir/sesame.png', labelKey: 'sesame'),
  'fish': AllergenInfo('Balık', '$_assetDir/fish.png', labelKey: 'fish'),
  'crustaceans': AllergenInfo(
      'Kabuklu deniz ürünleri', '$_assetDir/shellfish.png',
      labelKey: 'crustaceans'),
  'molluscs': AllergenInfo('Yumuşakçalar', '$_assetDir/mollusks.png',
      labelKey: 'molluscs'),
  'celery': AllergenInfo('Kereviz', '$_assetDir/celery.png', labelKey: 'celery'),
  'mustard':
      AllergenInfo('Hardal', '$_assetDir/mustard.png', labelKey: 'mustard'),
  'lupin': AllergenInfo('Acı bakla', '$_assetDir/lupin.png', labelKey: 'lupin'),
  'sulphur-dioxide-and-sulphites':
      AllergenInfo('Sülfitler', '$_assetDir/so2.png', labelKey: 'sulphites'),
};

/// Localized display name for an allergen. Falls back to [AllergenInfo.label]
/// for raw, unmapped tags.
String allergenLabel(AppLocalizations l10n, AllergenInfo info) =>
    switch (info.labelKey) {
      'gluten' => l10n.allergenGluten,
      'milk' => l10n.allergenMilk,
      'eggs' => l10n.allergenEggs,
      'soy' => l10n.allergenSoy,
      'peanuts' => l10n.allergenPeanuts,
      'nuts' => l10n.allergenNuts,
      'sesame' => l10n.allergenSesame,
      'fish' => l10n.allergenFish,
      'crustaceans' => l10n.allergenCrustaceans,
      'molluscs' => l10n.allergenMolluscs,
      'celery' => l10n.allergenCelery,
      'mustard' => l10n.allergenMustard,
      'lupin' => l10n.allergenLupin,
      'sulphites' => l10n.allergenSulphites,
      'unknown' => l10n.allergenUnknown,
      _ => info.label,
    };

/// Looks up [key]; unknown keys keep their name readable and fall back to
/// other.png so nothing disappears from the screen.
///
/// Raw Open Food Facts tags ("en:milk") are accepted too, so screens can still
/// render before the backend starts sending canonical keys.
AllergenInfo allergenInfo(String key) {
  final canonical = key.trim().replaceFirst(RegExp('^[a-z]{2}:'), '');

  final known = allergenCatalog[canonical];
  if (known != null) return known;

  final label = canonical.replaceAll(RegExp('[-_]'), ' ').trim();
  if (label.isEmpty) return _unknownAllergen;

  return AllergenInfo(
    label[0].toUpperCase() + label.substring(1),
    _unknownAllergen.asset,
  );
}
