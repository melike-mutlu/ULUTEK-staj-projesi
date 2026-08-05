import {
  normalize,
  resolveAllergenKeys,
  resolveAllergenKeysFromText,
} from "./allergen_dictionary.ts";
import {
  DIABETES_SUGAR_LIMIT,
  healthImplication,
} from "./health_dictionary.ts";

type Sufficiency = "sufficient" | "insufficient";
type HealthStatus = "conflict" | "ok" | "not_evaluated";

/**
 * Evaluates one health condition against the product. Unknown conditions and
 * anything we lack the data to judge return "not_evaluated" — never "ok", so a
 * condition is never silently reported as safe.
 */
function evaluateHealthCondition(
  condition: string,
  productKeys: Set<string>,
  nutriments: any,
  sufficiency: Sufficiency,
): HealthStatus {
  const implication = healthImplication(condition);
  if (!implication) return "not_evaluated";

  if (implication.allergens) {
    if (sufficiency === "insufficient") return "not_evaluated";
    const hit = implication.allergens.some((key) => productKeys.has(key));
    return hit ? "conflict" : "ok";
  }

  if (implication.nutrient) {
    const value = nutriments?.[implication.nutrient.field];
    if (value == null) return "not_evaluated";
    return value > implication.nutrient.max ? "conflict" : "ok";
  }

  return "not_evaluated";
}

/**
 * Diet keys the engine reacts to -> the labels the mobile app stores.
 * Labels come from apps/mobile/lib/core/constants/profile_options.dart; the key
 * itself is the legacy value written before diet_preference became text[].
 */
const DIET_ALIASES: Record<string, string[]> = {
  vegan: ["Vegan"],
  vegetarian: ["Vejetaryen"],
  sporcu: ["Sporcu / Yüksek protein"],
  diyabet_dostu: ["Diyabet dostu"],
};

/** diet_preference is text[], but old rows may still hold a single string. */
function hasDiet(profile: any, diet: string): boolean {
  const raw = profile?.diet_preference;
  const selected = Array.isArray(raw) ? raw : raw == null ? [] : [raw];
  const aliases = [diet, ...(DIET_ALIASES[diet] ?? [])].map(normalize);

  return selected.some((value) => aliases.includes(normalize(String(value))));
}

/**
 * Whether the product carries anything we can judge allergens with. Nutriments
 * do not count: this app answers "can I eat this", not "how caloric is it".
 */
function hasAllergenEvidence(product: any): boolean {
  const tags = product?.allergens_tags ?? [];
  const ingredients = String(product?.ingredients_text ?? "").trim();

  return tags.length > 0 || ingredients.length > 0;
}

export function runRuleEngine(product: any, profile: any) {
  const dataSufficiency: Sufficiency = hasAllergenEvidence(product)
    ? "sufficient"
    : "insufficient";

  // Empty entries would resolve to nothing but must not reach the dictionary.
  const userAllergies: string[] = (profile?.allergies ?? [])
    .map((allergy: unknown) => String(allergy ?? "").trim())
    .filter((allergy: string) => allergy.length > 0);

  // 1. Alerjen Eşleşmesi Kontrolü
  // Both sides are resolved to canonical keys and intersected; no substring
  // matching, so "Süt/Laktoz" matches "en:milk" but never "en:milk-chocolate".
  // Tags come first (authoritative), then anything found in the ingredients
  // text — so milk written only in the ingredients is still caught.
  const productKeys: string[] = [];
  const addKey = (key: string) => {
    if (!productKeys.includes(key)) productKeys.push(key);
  };
  for (const tag of product.allergens_tags ?? []) {
    resolveAllergenKeys(String(tag)).forEach(addKey);
  }
  resolveAllergenKeysFromText(String(product.ingredients_text ?? "")).forEach(
    addKey,
  );
  const productKeySet = new Set(productKeys);

  const profileKeys = new Set(
    userAllergies.flatMap((allergy) => resolveAllergenKeys(allergy)),
  );

  // Kept as the user's original profile strings — existing consumers read this.
  const matched = userAllergies.filter((allergy) =>
    resolveAllergenKeys(allergy).some((key) => productKeySet.has(key))
  );

  // Every allergen found on the product, in tag order; matched=false means the
  // product has it but the profile does not.
  const allergens = productKeys.map((key) => ({
    key,
    matched: profileKeys.has(key),
  }));

  // 2. Vegan Uyumluluk Kontrolü (ürünün kendisi vegan mı?)
  const ingredients = (product.ingredients_text || "").toLowerCase();
  const allergensTags = product.allergens_tags || [];

  const nonVeganKeywords = [
    "süt", "milk", "peynir", "cheese", "yoğurt", "yogurt", "tereyağı", "butter",
    "yumurta", "egg", "bal", "honey", "et", "meat", "tavuk", "chicken", "jelatin", "gelatin"
  ];

  const hasNonVeganIngredient = nonVeganKeywords.some((keyword) => ingredients.includes(keyword));
  const hasNonVeganAllergen = allergensTags.some((tag: string) =>
    ["milk", "egg", "fish", "meat"].some((nonVeganTag) => tag.toLowerCase().includes(nonVeganTag))
  );

  // null = unknown. With no allergen evidence we cannot claim the product is
  // plant based; absence of a match is not proof of compatibility.
  const isVeganCompatible: boolean | null = dataSufficiency === "insufficient"
    ? null
    : !hasNonVeganIngredient && !hasNonVeganAllergen;

  // Vejetaryen: yalnızca et/balık/jelatin dışlanır; süt ve yumurta serbesttir.
  // Bare "et" is avoided on purpose so "petit"/"beta" are not false positives;
  // meat is caught through its explicit forms instead.
  const nonVegetarianKeywords = [
    "et suyu", "kırmızı et", "dana eti", "kuzu eti", "tavuk eti", "hindi eti",
    "sığır eti", "meat", "tavuk", "chicken", "hindi", "dana", "kuzu", "domuz",
    "sosis", "salam", "sucuk", "jambon", "kıyma", "biftek", "balık", "fish",
    "karides", "jelatin", "gelatin",
  ];

  const hasNonVegetarianIngredient = nonVegetarianKeywords.some((keyword) =>
    ingredients.includes(keyword)
  );
  const hasNonVegetarianAllergen = allergensTags.some((tag: string) =>
    ["fish", "meat", "crustaceans"].some((t) => tag.toLowerCase().includes(t))
  );

  const isVegetarianCompatible: boolean | null =
    dataSufficiency === "insufficient"
      ? null
      : !hasNonVegetarianIngredient && !hasNonVegetarianAllergen;

  // 2.5 Sağlık Durumu Kontrolü — profildeki her koşul ürüne karşı değerlendirilir.
  const healthConditionInputs: string[] = (profile?.health_conditions ?? [])
    .map((condition: unknown) => String(condition ?? "").trim())
    .filter((condition: string) => condition.length > 0);

  const healthConditions = healthConditionInputs.map((condition) => ({
    condition,
    status: evaluateHealthCondition(
      condition,
      productKeySet,
      product.nutriments,
      dataSufficiency,
    ),
  }));

  const hasHealthConflict = healthConditions.some((h) => h.status === "conflict");

  // 3. Diyabet Değerlendirmesi (Şeker Oranına Göre, herkes için bilgilendirici)
  const sugars = product.nutriments?.sugars_100g ?? product.nutriments?.sugars ?? 0;
  let diabeticNote: string | null = null;

  if (sugars > 15) {
    diabeticNote = "Yüksek şeker oranı! Diyabet hastaları için önerilmez.";
  } else if (sugars > 5) {
    diabeticNote = "Orta seviye şeker oranı. Tüketirken dikkat edilmeli.";
  } else {
    diabeticNote = "Düşük şeker oranı. Diyabet dostu.";
  }

  // 4. Sporcu Profili Kontrolü (Protein Oranına Göre — PRD Senaryo 2)
  const proteins = product.nutriments?.proteins_100g ?? product.nutriments?.proteins ?? 0;
  let athleteNote: string | null = null;
  let isLowProteinForAthlete = false;

  const isVeganUser = hasDiet(profile, "vegan");
  const isVegetarianUser = hasDiet(profile, "vegetarian");
  const isAthleteUser = hasDiet(profile, "sporcu");
  const isDiabeticDietUser = hasDiet(profile, "diyabet_dostu");

  if (isAthleteUser) {
    if (proteins < 5) {
      athleteNote = "Düşük protein oranı! Sporcu beslenmesi için yetersiz (Kırmızı Uyarı).";
      isLowProteinForAthlete = true;
    } else if (proteins <= 15) {
      athleteNote = "Orta seviye protein oranı (Sarı Uyarı).";
    } else {
      athleteNote = "Yüksek protein oranı! Sporcu dostu ürün.";
    }
  }

  // Çakışma Kontrolleri
  // Only a known incompatibility counts; unknown (null) is neither conflict nor
  // safety, so it never flips the verdict either way.
  const hasVeganConflict = isVeganUser && isVeganCompatible === false;
  const hasVegetarianConflict = isVegetarianUser &&
    isVegetarianCompatible === false;
  const hasAthleteConflict = isLowProteinForAthlete;
  // "Diyabet dostu" diet mirrors the "Şeker hastalığı" condition on the diet axis.
  const hasDiabeticDietConflict = isDiabeticDietUser &&
    sugars > DIABETES_SUGAR_LIMIT;

  // The top verdict must reflect every red row the screen can show: allergen
  // matches, diet conflicts (vegan/athlete/diabetic) and health conditions.
  const hasConflict = matched.length > 0 ||
    hasVeganConflict ||
    hasVegetarianConflict ||
    hasAthleteConflict ||
    hasDiabeticDietConflict ||
    hasHealthConflict;

  return {
    matched_allergens: matched,
    allergens,
    // Per health condition: "conflict" | "ok" | "not_evaluated". Consumers must
    // treat "not_evaluated" as "kontrol edilemedi", never as safe.
    health_conditions: healthConditions,
    // "insufficient" means the product carries no allergen evidence at all.
    // The verdict then can neither be trusted as "uygun" nor as a conflict;
    // consumers must show "yetersiz veri" and ignore has_conflict.
    data_sufficiency: dataSufficiency,
    has_conflict: hasConflict,
    diet_flags: {
      vegan_compatible: isVeganCompatible,
      vegetarian_compatible: isVegetarianCompatible,
      diabetic_note: diabeticNote,
      athlete_note: athleteNote,
      protein_100g: proteins,
    },
  };
}

/**
 * Drives the "partial" status: only nutriments here, on purpose. Missing
 * allergen data is a separate concern carried by `data_sufficiency`, so a
 * product with full nutriments but no allergen tags stays status=found.
 */
export function findMissingFields(product: any) {
  const missing: string[] = [];
  const n = product.nutriments;
  if (!n || Object.values(n).every((v) => v == null)) missing.push("nutriments");
  return missing;
}
