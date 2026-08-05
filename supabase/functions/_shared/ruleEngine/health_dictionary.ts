import { normalize } from "./allergen_dictionary.ts";

/** A nutrient limit: the product conflicts when its value exceeds [max]. */
export interface NutrientLimit {
  /** Key under product.nutriments, e.g. "sugars_100g". */
  field: string;
  max: number;
}

/** What a health condition implies about a product. */
export interface HealthImplication {
  /** Canonical allergen keys (see allergen_dictionary) the condition avoids. */
  allergens?: string[];
  /** A nutrient the condition must stay under. */
  nutrient?: NutrientLimit;
}

/** Sugar per 100 g above which a diabetic profile should be warned. Shared by
 * the "Şeker hastalığı" condition and the "Diyabet dostu" diet. */
export const DIABETES_SUGAR_LIMIT = 15;

/** g/100 g ceilings (UK FSA "high" reference values). */
const SALT_LIMIT = 1.5;
const SATURATED_FAT_LIMIT = 5;

/**
 * Canonical health-condition label (see profile_options.dart) -> implication.
 * Only medically clear mappings live here; a new condition is one entry.
 * Conditions absent from this map are reported "not evaluated", never "safe".
 */
export const HEALTH_IMPLICATIONS: Record<string, HealthImplication> = {
  "çölyak": { allergens: ["gluten"] },
  "laktoz intoleransı": { allergens: ["milk"] },
  "şeker hastalığı": {
    nutrient: { field: "sugars_100g", max: DIABETES_SUGAR_LIMIT },
  },
  "tansiyon": { nutrient: { field: "salt_100g", max: SALT_LIMIT } },
  "yüksek tansiyon": { nutrient: { field: "salt_100g", max: SALT_LIMIT } },
  "yüksek kolesterol": {
    nutrient: { field: "saturated_fat_100g", max: SATURATED_FAT_LIMIT },
  },
  "kalp rahatsızlığı": {
    nutrient: { field: "saturated_fat_100g", max: SATURATED_FAT_LIMIT },
  },
};

/** Exact-match lookup after TR-aware normalization; null when unmapped. */
export function healthImplication(condition: string): HealthImplication | null {
  return HEALTH_IMPLICATIONS[normalize(condition)] ?? null;
}
