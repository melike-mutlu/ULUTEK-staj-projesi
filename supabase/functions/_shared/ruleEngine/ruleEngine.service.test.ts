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

Deno.test("findMissingFields alerjen ve içindekiler eksikliğini bildirir", () => {
  const missing = findMissingFields(
    product({ allergens_tags: [], ingredients_text: "  " }),
  );

  assertEquals(missing.includes("allergens_tags"), true);
  assertEquals(missing.includes("ingredients_text"), true);

  const complete = findMissingFields(
    product({ allergens_tags: ["en:milk"], ingredients_text: "Süt" }),
  );
  assertEquals(complete.includes("allergens_tags"), false);
  assertEquals(complete.includes("ingredients_text"), false);
});
