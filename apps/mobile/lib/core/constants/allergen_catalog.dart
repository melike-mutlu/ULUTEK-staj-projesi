/// Display name and icon for a canonical allergen key.
class AllergenInfo {
  const AllergenInfo(this.label, this.asset);

  final String label;
  final String asset;
}

const String _assetDir = 'assets/allergens';

/// Shown when the backend sends a key we have no icon for.
const AllergenInfo _unknownAllergen =
    AllergenInfo('Bilinmeyen alerjen', '$_assetDir/other.png');

/// Canonical key (the bare Open Food Facts token the rule engine returns)
/// -> label + icon. File names do not follow the keys, so the mapping is
/// explicit. A new allergen = one new entry here.
const Map<String, AllergenInfo> allergenCatalog = <String, AllergenInfo>{
  'gluten': AllergenInfo('Gluten', '$_assetDir/gluten.png'),
  'milk': AllergenInfo('Süt / Laktoz', '$_assetDir/milk.png'),
  'eggs': AllergenInfo('Yumurta', '$_assetDir/egg.png'),
  'soybeans': AllergenInfo('Soya', '$_assetDir/soy.png'),
  'peanuts': AllergenInfo('Yer fıstığı', '$_assetDir/peanut.png'),
  'nuts': AllergenInfo('Kabuklu yemişler', '$_assetDir/nuts_and_dried_fruits.png'),
  'sesame-seeds': AllergenInfo('Susam', '$_assetDir/sesame.png'),
  'fish': AllergenInfo('Balık', '$_assetDir/fish.png'),
  'crustaceans': AllergenInfo('Kabuklu deniz ürünleri', '$_assetDir/shellfish.png'),
  'molluscs': AllergenInfo('Yumuşakçalar', '$_assetDir/mollusks.png'),
  'celery': AllergenInfo('Kereviz', '$_assetDir/celery.png'),
  'mustard': AllergenInfo('Hardal', '$_assetDir/mustard.png'),
  'lupin': AllergenInfo('Acı bakla', '$_assetDir/lupin.png'),
  'sulphur-dioxide-and-sulphites':
      AllergenInfo('Sülfitler', '$_assetDir/so2.png'),
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
