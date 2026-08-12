import { normalize } from "./allergen_dictionary.ts";

/** Carbohydrate per 100 g ceilings. Keto is stricter than general low-carb. */
export const KETO_CARB_LIMIT = 10;
export const LOW_CARB_LIMIT = 25;

/** What a diet implies about a product. */
export interface DietImplication {
  /** Canonical allergen keys the diet excludes. */
  allergens?: string[];
  /** A nutrient the diet must stay under. */
  maxNutrient?: { field: string; max: number };
}

/**
 * Canonical diet label (see profile_options.dart) -> implication. Covers the
 * threshold/allergen diets; vegan/vegetarian/sporcu/diyabet keep their own
 * logic in the rule engine. A new diet is one entry here.
 */
export const DIET_IMPLICATIONS: Record<string, DietImplication> = {
  "glutensiz yaşam tarzı": { allergens: ["gluten"] },
  "ketojenik": {
    maxNutrient: { field: "carbohydrates_100g", max: KETO_CARB_LIMIT },
  },
  "düşük karbonhidrat": {
    maxNutrient: { field: "carbohydrates_100g", max: LOW_CARB_LIMIT },
  },
};

/** Exact-match lookup after TR-aware normalization; null when unmapped. */
export function dietImplication(diet: string): DietImplication | null {
  return DIET_IMPLICATIONS[normalize(diet)] ?? null;
}
