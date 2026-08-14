const OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v2/product";
const OFF_SEARCH_URL = "https://world.openfoodfacts.org";

export interface OffProduct {
  barcode: string;
  name: string;
  brand: string | null;
  ingredients_text: string;
  additives: string[];
  allergens_tags: string[];
  /** "May contain" tags — a weaker signal than allergens_tags. */
  traces_tags: string[];
  /** OFF's own diet analysis: en:vegan / en:non-vegan / en:maybe-vegan, etc. */
  ingredients_analysis_tags: string[];
  /** Producer labels, e.g. en:vegan, en:vegetarian, en:gluten-free. */
  labels_tags: string[];
  /** OFF category tags, e.g. en:snacks — used to find same-category alternatives. */
  categories_tags: string[];
  nutriments: {
    energy_kcal_100g: number | null;
    sugars_100g: number | null;
    fat_100g: number | null;
    saturated_fat_100g: number | null;
    carbohydrates_100g: number | null;
    proteins_100g: number | null;
    salt_100g: number | null;
  };
  nutriscore: string | null;
  image_url: string | null; //  1. Arayüze eklendi
}
function categoryToSearchTerm(category: string): string {
  const tag = category.replace(/^en:/, "");

  if (tag.includes("crispbread")) return "crispbreads";
  if (tag.includes("cracker")) return "crackers";
  if (tag.includes("crisps")) return "crisps";
  if (tag.includes("bread")) return "breads";

  return tag.replace(/-/g, " ");
}

export async function fetchFromOpenFoodFacts(barcode: string): Promise<OffProduct | null> {
  const res = await fetch(`${OFF_PRODUCT_URL}/${barcode}.json`, {
    headers: { "User-Agent": "AkilliSepet - Backend - Version 1.0" },
  });
  const json = await res.json();
  if (json.status !== 1) return null;

  const p = json.product;
  return {
    barcode,
    name: p.product_name ?? "",
    brand: p.brands ?? null,
    ingredients_text: p.ingredients_text ?? "",
    additives: p.additives_tags ?? [],
    allergens_tags: p.allergens_tags ?? [],
    traces_tags: p.traces_tags ?? [],
    ingredients_analysis_tags: p.ingredients_analysis_tags ?? [],
    labels_tags: p.labels_tags ?? [],
    categories_tags: p.categories_tags ?? [],
    nutriments: {
      energy_kcal_100g: p.nutriments?.["energy-kcal_100g"] ?? null,
      sugars_100g: p.nutriments?.sugars_100g ?? null,
      fat_100g: p.nutriments?.fat_100g ?? null,
      saturated_fat_100g: p.nutriments?.["saturated-fat_100g"] ?? null,
      carbohydrates_100g: p.nutriments?.carbohydrates_100g ?? null,
      proteins_100g: p.nutriments?.proteins_100g ?? null,
      salt_100g: p.nutriments?.salt_100g ?? null,
    },
    nutriscore: p.nutriscore_grade ?? null,
    image_url: p.image_front_url ?? p.image_url ?? null, //  2. Dönüş objesine eklendi
  };
}
export async function searchProductsByCategory(
  category: string,
  pageSize = 15,
): Promise<OffProduct[]> {
  const searchTerm = categoryToSearchTerm(category);

  const url =
    `${OFF_SEARCH_URL}/cgi/search.pl?` +
    `search_terms=${encodeURIComponent(searchTerm)}` +
    `&search_simple=1` +
    `&action=process` +
    `&json=1` +
    `&page_size=${pageSize}`;

  const res = await fetch(url, {
    headers: {
      "User-Agent": "AkilliSepet/1.0 (contact@example.com)",
    },
  });

  if (!res.ok) {
    console.error("OFF category search failed:", res.status);
    return [];
  }

  const data = await res.json();

  console.log(
    "OFF search term:",
    searchTerm,
    "count:",
    data.products?.length ?? 0,
  );

  return (data.products ?? []).map((p: any) => ({
    barcode: p.code,
    name: p.product_name ?? "Bilinmeyen Ürün",
    brand: p.brands ?? null,
    ingredients_text: p.ingredients_text ?? "",
    additives: p.additives_tags ?? [],
    allergens_tags: p.allergens_tags ?? [],
    traces_tags: p.traces_tags ?? [],
    ingredients_analysis_tags: p.ingredients_analysis_tags ?? [],
    labels_tags: p.labels_tags ?? [],
    categories_tags: p.categories_tags ?? [],
    nutriments: {
      energy_kcal_100g: p.nutriments?.["energy-kcal_100g"] ?? null,
      sugars_100g: p.nutriments?.sugars_100g ?? null,
      fat_100g: p.nutriments?.fat_100g ?? null,
      saturated_fat_100g: p.nutriments?.["saturated-fat_100g"] ?? null,
      carbohydrates_100g: p.nutriments?.carbohydrates_100g ?? null,
      proteins_100g: p.nutriments?.proteins_100g ?? null,
      salt_100g: p.nutriments?.salt_100g ?? null,
    },
    nutriscore: p.nutrition_grades?.toUpperCase() ?? null,
    image_url: p.image_front_url ?? null,
  }));
}