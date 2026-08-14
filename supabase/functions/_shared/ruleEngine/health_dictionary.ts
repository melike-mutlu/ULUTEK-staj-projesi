import { normalize } from "./allergen_dictionary.ts";

export interface NutrientLimit {
  field: string;
  max: number;
}

export interface HealthImplication {
  allergens?: string[];
  nutrient?: NutrientLimit;
  nutrients?: NutrientLimit[];
}

export const DIABETES_SUGAR_LIMIT = 15;
export const SALT_LIMIT = 1.5;
export const TOTAL_FAT_LIMIT = 15;
export const SATURATED_FAT_LIMIT = 3;

export const HEALTH_IMPLICATIONS: Record<string, HealthImplication> = {
  "çölyak": {
    allergens: ["gluten"],
  },

  "laktoz intoleransı": {
    allergens: ["milk"],
  },

  "şeker hastalığı": {
    nutrient: { field: "sugars_100g", max: DIABETES_SUGAR_LIMIT },
  },

  "tansiyon": {
    nutrient: { field: "salt_100g", max: SALT_LIMIT },
  },

  "yüksek tansiyon": {
    nutrient: { field: "salt_100g", max: SALT_LIMIT },
  },

 "yüksek kolesterol": {
  nutrients: [
    { field: "fat_100g", max: TOTAL_FAT_LIMIT },
    { field: "saturated_fat_100g", max: SATURATED_FAT_LIMIT },
  ],
},

  "kalp rahatsızlığı": {
  nutrients: [
    { field: "salt_100g", max: SALT_LIMIT },
    { field: "fat_100g", max: TOTAL_FAT_LIMIT },
    { field: "saturated_fat_100g", max: SATURATED_FAT_LIMIT },
  ],
},

  "böbrek hastalığı": {
    nutrient: { field: "salt_100g", max: SALT_LIMIT },
  },
};

export function healthImplication(condition: string): HealthImplication | null {
  return HEALTH_IMPLICATIONS[normalize(condition)] ?? null;
}
