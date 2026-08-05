import { assertEquals } from "jsr:@std/assert@^1";
import { findMissingFields, runRuleEngine } from "./ruleEngine.service.ts";

function product(overrides: Record<string, unknown> = {}) {
  return {
    barcode: "8690000000000",
    ingredients_text: "",
    allergens_tags: [] as string[],
    nutriments: { sugars_100g: 0, proteins_100g: 0 },
    ...overrides,
  };
}

Deno.test("TR profil etiketi EN tag ile eşleşir: Süt/Laktoz -> en:milk", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:milk"] }),
    { allergies: ["Süt/Laktoz"] },
  );

  assertEquals(result.matched_allergens, ["Süt/Laktoz"]);
  assertEquals(result.has_conflict, true);
});

Deno.test("Soya -> en:soybeans eşleşir", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:soybeans"] }),
    { allergies: ["Soya"] },
  );

  assertEquals(result.matched_allergens, ["Soya"]);
});

Deno.test("Susam -> en:sesame-seeds eşleşir", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:sesame-seeds"] }),
    { allergies: ["Susam"] },
  );

  assertEquals(result.matched_allergens, ["Susam"]);
});

Deno.test("Sözlükte olmayan tag kaybolmaz ve aynı değerle eşleşir", () => {
  const detectedOnly = runRuleEngine(
    product({ allergens_tags: ["en:kiwi"] }),
    { allergies: [] },
  );
  assertEquals(detectedOnly.allergens, [{ key: "kiwi", matched: false }]);

  const matchedByUser = runRuleEngine(
    product({ allergens_tags: ["en:kiwi"] }),
    { allergies: ["kiwi"] },
  );
  assertEquals(matchedByUser.matched_allergens, ["kiwi"]);
});

Deno.test("Boş / boşluklu / null alerji girdisi yanlış eşleşme üretmez", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:milk"] }),
    { allergies: ["", "   ", null] },
  );

  assertEquals(result.matched_allergens, []);
  assertEquals(result.has_conflict, false);
});

Deno.test("diet_preference text[] olarak okunur: ['Vegan']", () => {
  const veganUser = runRuleEngine(
    product({ ingredients_text: "Buğday unu, süt tozu, şeker." }),
    { allergies: [], diet_preference: ["Vegan"] },
  );
  assertEquals(veganUser.has_conflict, true);

  const noDiet = runRuleEngine(
    product({ ingredients_text: "Buğday unu, süt tozu, şeker." }),
    { allergies: [], diet_preference: [] },
  );
  assertEquals(noDiet.has_conflict, false);
});

Deno.test("diet_preference eski tekil string olarak da okunur: 'vegan'", () => {
  const result = runRuleEngine(
    product({ ingredients_text: "Buğday unu, süt tozu, şeker." }),
    { allergies: [], diet_preference: "vegan" },
  );

  assertEquals(result.has_conflict, true);
});

Deno.test("allergens alanı matched ve detected-only alerjenleri ayırır", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:milk", "en:nuts"] }),
    { allergies: ["Süt/Laktoz"] },
  );

  assertEquals(result.allergens, [
    { key: "milk", matched: true },
    { key: "nuts", matched: false },
  ]);
});

Deno.test("alerjen kanıtı yoksa veri yetersiz sayılır", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "" }),
    { allergies: ["Süt/Laktoz"] },
  );

  assertEquals(result.data_sufficiency, "insufficient");
});

Deno.test("besin değerleri tek başına veriyi yeterli yapmaz", () => {
  const result = runRuleEngine(
    product({ nutriments: { sugars_100g: 1.4, proteins_100g: 13.5 } }),
    { allergies: [] },
  );

  assertEquals(result.data_sufficiency, "insufficient");
});

Deno.test("sadece içindekiler bile veriyi yeterli yapar", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Süt, tuz, maya" }),
    { allergies: [] },
  );

  assertEquals(result.data_sufficiency, "sufficient");
});

Deno.test("findMissingFields yalnızca nutriments eksikliğini bildirir", () => {
  // Alerjen/içindekiler eksikliği status'ü değil, data_sufficiency'yi etkiler.
  const missing = findMissingFields(
    product({ allergens_tags: [], ingredients_text: "  ", nutriments: { sugars_100g: 5 } }),
  );
  assertEquals(missing, []);

  const noNutriments = findMissingFields(
    product({ nutriments: {} }),
  );
  assertEquals(noNutriments, ["nutriments"]);
});

Deno.test("veri yetersizken vegan uyumu bilinmiyor (null) döner", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "" }),
    { allergies: [], diet_preference: ["Vegan"] },
  );

  assertEquals(result.diet_flags.vegan_compatible, null);
  // Unknown must not surface as a conflict either.
  assertEquals(result.has_conflict, false);
});

Deno.test("veri yeterliyken bilinen uyumsuzluk vegan çakışması üretir", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Süt, tuz, maya" }),
    { allergies: [], diet_preference: ["Vegan"] },
  );

  assertEquals(result.diet_flags.vegan_compatible, false);
  assertEquals(result.has_conflict, true);
});

Deno.test("veri yeterli ve ürün bitkiselse vegan uyumlu döner", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Nohut, zeytinyağı, tuz" }),
    { allergies: [], diet_preference: ["Vegan"] },
  );

  assertEquals(result.diet_flags.vegan_compatible, true);
  assertEquals(result.has_conflict, false);
});

Deno.test("içindekiler taranarak alerjen eşleşmesi bulunur (etiket yokken)", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Süt, tuz, maya, peynir kültürü" }),
    { allergies: ["Süt/Laktoz"] },
  );

  assertEquals(result.matched_allergens, ["Süt/Laktoz"]);
  assertEquals(result.allergens, [{ key: "milk", matched: true }]);
  assertEquals(result.has_conflict, true);
});

Deno.test("içindekiler taraması alt dize yanlış pozitifi üretmez", () => {
  // "et" (meat is not a dictionary key anyway) — arpa vs şarap benzeri
  // durumları kontrol et: "arpa" gluten sinonimi, "şarap" eşleşmemeli.
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Şarap sirkesi, su, tuz" }),
    { allergies: ["Gluten"] },
  );

  assertEquals(result.matched_allergens, []);
  assertEquals(result.allergens, []);
});

Deno.test("çok kelimeli sinonim ancak bitişik geçince eşleşir", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Antep fıstığı, şeker" }),
    { allergies: [] },
  );

  assertEquals(result.allergens, [{ key: "nuts", matched: false }]);
});

Deno.test("Çölyak + glutenli ürün sağlık çakışması üretir", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:gluten"], ingredients_text: "Buğday unu" }),
    { allergies: [], health_conditions: ["Çölyak"] },
  );

  assertEquals(result.health_conditions, [
    { condition: "Çölyak", status: "conflict" },
  ]);
  assertEquals(result.has_conflict, true);
});

Deno.test("Çölyak + glutensiz ürün uygun döner", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:milk"], ingredients_text: "Süt" }),
    { allergies: [], health_conditions: ["Çölyak"] },
  );

  assertEquals(result.health_conditions, [{ condition: "Çölyak", status: "ok" }]);
  assertEquals(result.has_conflict, false);
});

Deno.test("Laktoz intoleransı sütlü üründe çakışır", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "Süt, tuz" }),
    { allergies: [], health_conditions: ["Laktoz intoleransı"] },
  );

  assertEquals(result.health_conditions[0].status, "conflict");
  assertEquals(result.has_conflict, true);
});

Deno.test("bilinmeyen sağlık durumu 'not_evaluated' döner, güvenli sayılmaz", () => {
  const result = runRuleEngine(
    product({ allergens_tags: ["en:milk"], ingredients_text: "Süt" }),
    { allergies: [], health_conditions: ["Tansiyon"] },
  );

  assertEquals(result.health_conditions, [
    { condition: "Tansiyon", status: "not_evaluated" },
  ]);
  assertEquals(result.has_conflict, false);
});

Deno.test("veri yetersizken sağlık alerjen kontrolü değerlendirilemez", () => {
  const result = runRuleEngine(
    product({ allergens_tags: [], ingredients_text: "" }),
    { allergies: [], health_conditions: ["Çölyak"] },
  );

  assertEquals(result.health_conditions[0].status, "not_evaluated");
});

Deno.test("Şeker hastalığı yüksek şekerli üründe çakışır", () => {
  const result = runRuleEngine(
    product({
      allergens_tags: ["en:milk"],
      ingredients_text: "Süt, şeker",
      nutriments: { sugars_100g: 38 },
    }),
    { allergies: [], health_conditions: ["Şeker hastalığı"] },
  );

  assertEquals(result.health_conditions[0].status, "conflict");
  assertEquals(result.has_conflict, true);
});
