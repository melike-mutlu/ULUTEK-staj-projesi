// Open Food Facts API ile iletişim kuran servis dosyası.
// Ürün bilgisi çekmek isteyen her fonksiyon burayı kullanır.

const OFF_BASE_URL = "https://world.openfoodfacts.org/api/v2/product";

export async function fetchFromOpenFoodFacts(barcode: string) {
  const res = await fetch(`${OFF_BASE_URL}/${barcode}.json`);
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
  };
}