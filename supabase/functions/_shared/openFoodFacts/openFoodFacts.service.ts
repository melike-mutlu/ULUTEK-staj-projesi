const OFF_BASE_URL = "https://world.openfoodfacts.org/api/v2/product";

export interface OffProduct {
  barcode: string;
  name: string;
  ingredients_text: string;
  additives: string[];
  allergens_tags: string[];
  nutriments: {
    energy_kcal_100g: number | null;
    sugars_100g: number | null;
    fat_100g: number | null;
    proteins_100g: number | null;
    salt_100g: number | null;
  };
  nutriscore: string | null;
  image_url: string | null; //  1. Arayüze eklendi
}

export async function fetchFromOpenFoodFacts(barcode: string): Promise<OffProduct | null> {
  const res = await fetch(`${OFF_BASE_URL}/${barcode}.json`, {
    headers: { "User-Agent": "AkilliSepet - Backend - Version 1.0" },
  });
  const json = await res.json();
  if (json.status !== 1) return null;

  const p = json.product;
  return {
    barcode,
    name: p.product_name ?? "",
    ingredients_text: p.ingredients_text ?? "",
    additives: p.additives_tags ?? [],
    allergens_tags: p.allergens_tags ?? [],
    nutriments: {
      energy_kcal_100g: p.nutriments?.["energy-kcal_100g"] ?? null,
      sugars_100g: p.nutriments?.sugars_100g ?? null,
      fat_100g: p.nutriments?.fat_100g ?? null,
      proteins_100g: p.nutriments?.proteins_100g ?? null,
      salt_100g: p.nutriments?.salt_100g ?? null,
    },
    nutriscore: p.nutriscore_grade ?? null,
    image_url: p.image_front_url ?? p.image_url ?? null, //  2. Dönüş objesine eklendi
  };
}