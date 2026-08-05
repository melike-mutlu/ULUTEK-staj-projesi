/**
 * Allergen dictionary — the single bridge between the three vocabularies used
 * in the app:
 *   - Open Food Facts tags        ("en:milk", "en:sesame-seeds")
 *   - mobile profile labels       ("Süt/Laktoz", "Fındık/Fıstık")
 *     see apps/mobile/lib/core/constants/profile_options.dart
 *   - free text the user typed via the "+" chip
 *
 * The canonical key is the bare OFF token, so a product tag resolves to its own
 * key by construction.
 *
 * Adding an allergen = one new entry here. The matching logic never changes.
 */

/** Canonical key -> synonyms. The key itself is always a synonym. */
export const ALLERGEN_SYNONYMS: Record<string, string[]> = {
  gluten: ["Gluten", "buğday", "wheat", "arpa", "barley", "çavdar", "rye"],
  milk: ["Süt/Laktoz", "süt", "laktoz", "lactose", "dairy", "peynir", "cheese"],
  eggs: ["Yumurta", "egg"],
  soybeans: ["Soya", "soy", "soya fasulyesi"],
  // "Fındık/Fıstık" is one label in the mobile catalog but covers both tree
  // nuts and peanuts, so it is listed under both keys on purpose.
  nuts: [
    "Fındık/Fıstık",
    "fındık",
    "hazelnut",
    "ceviz",
    "walnut",
    "badem",
    "almond",
    "antep fıstığı",
    "pistachio",
    "kaju",
    "cashew",
    "tree nuts",
  ],
  peanuts: ["Fındık/Fıstık", "yer fıstığı", "peanut"],
  fish: ["Balık", "balik"],
  crustaceans: [
    "Kabuklu deniz ürünleri",
    "kabuklu",
    "karides",
    "shrimp",
    "yengeç",
    "crab",
    "istakoz",
    "lobster",
  ],
  molluscs: ["midye", "mussel", "kalamar", "squid", "istiridye", "oyster"],
  "sesame-seeds": ["Susam", "sesame", "sesame seeds"],
  celery: ["Kereviz"],
  mustard: ["Hardal"],
  lupin: ["Acı bakla", "lupen"],
  "sulphur-dioxide-and-sulphites": ["Sülfit", "sulfit", "kükürt dioksit"],
};

/**
 * Turkish-aware lowercase + trim. "İ"/"I" are mapped before toLowerCase(),
 * which would otherwise turn "I" into "i" instead of "ı".
 */
export function normalize(value: string): string {
  return value
    .replace(/İ/g, "i")
    .replace(/I/g, "ı")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

/** Normalized synonym -> canonical keys (a synonym may belong to several). */
const SYNONYM_INDEX: Map<string, string[]> = (() => {
  const index = new Map<string, string[]>();
  for (const [key, synonyms] of Object.entries(ALLERGEN_SYNONYMS)) {
    for (const synonym of [key, ...synonyms]) {
      const token = normalize(synonym);
      const keys = index.get(token) ?? [];
      if (!keys.includes(key)) keys.push(key);
      index.set(token, keys);
    }
  }
  return index;
})();

/**
 * Resolves an OFF tag or a profile value to its canonical key(s).
 * Exact lookup only — no substring matching.
 *
 * An unmapped value becomes its own key ("en:mustard" -> "mustard") so it stays
 * visible and still matches an identical value from the other side.
 */
export function resolveAllergenKeys(value: string): string[] {
  const token = normalize(value).replace(/^[a-z]{2}:/, "");
  if (!token) return [];
  return SYNONYM_INDEX.get(token) ?? [token];
}

/** Word tokens of a normalized text, split on anything that is not a letter. */
function tokenize(text: string): string[] {
  return normalize(text)
    .split(/[^a-zçğıöşü0-9]+/)
    .filter((token) => token.length > 0);
}

/** True when [phrase] appears as consecutive whole tokens inside [tokens]. */
function containsPhrase(tokens: string[], phrase: string[]): boolean {
  for (let i = 0; i + phrase.length <= tokens.length; i++) {
    if (phrase.every((word, j) => tokens[i + j] === word)) return true;
  }
  return false;
}

/**
 * Scans free-text ingredients for known allergen synonyms and returns the
 * canonical keys found. Whole-word / whole-phrase only — "et" never matches
 * inside "petit", so no substring false positives.
 */
export function resolveAllergenKeysFromText(text: string): string[] {
  const tokens = tokenize(text);
  if (tokens.length === 0) return [];

  const found: string[] = [];
  for (const [synonym, keys] of SYNONYM_INDEX) {
    if (!containsPhrase(tokens, synonym.split(" "))) continue;
    for (const key of keys) {
      if (!found.includes(key)) found.push(key);
    }
  }
  return found;
}
