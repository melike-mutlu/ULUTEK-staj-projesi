import {
  normalize,
  resolveAllergenKeys,
  resolveAllergenKeysFromText,
} from "./allergen_dictionary.ts";
import {
  DIABETES_SUGAR_LIMIT,
  healthImplication,
} from "./health_dictionary.ts";
import { dietImplication } from "./diet_dictionary.ts";

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
 * Evaluates a dictionary-driven diet ("Glutensiz yaşam tarzı", "Ketojenik",
 * "Düşük karbonhidrat") against the product. Unknown diets and missing data
 * yield "not_evaluated", never a silent "ok".
 */
function evaluateDietImplication(
  diet: string,
  productKeys: Set<string>,
  nutriments: any,
  sufficiency: Sufficiency,
): HealthStatus {
  const implication = dietImplication(diet);
  if (!implication) return "not_evaluated";

  if (implication.allergens) {
    if (sufficiency === "insufficient") return "not_evaluated";
    const hit = implication.allergens.some((key) => productKeys.has(key));
    return hit ? "conflict" : "ok";
  }

  if (implication.maxNutrient) {
    const value = nutriments?.[implication.maxNutrient.field];
    if (value == null) return "not_evaluated";
    return value > implication.maxNutrient.max ? "conflict" : "ok";
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

/**
 * Diet compatibility for [diet] ("vegan" | "vegetarian").
 * OFF is authoritative: explicit non-X → false, X (analysis or label) → true,
 * maybe-X → null (unknown). Only when OFF says nothing do we fall back to the
 * keyword guess. Insufficient allergen data always yields null.
 */
function resolveDietCompatibility(
  diet: string,
  analysisTags: string[],
  labelsTags: string[],
  sufficiency: Sufficiency,
  keywordCompatible: boolean,
): boolean | null {
  if (sufficiency === "insufficient") return null;

  if (analysisTags.includes(`en:non-${diet}`)) return false;
  if (analysisTags.includes(`en:${diet}`) || labelsTags.includes(`en:${diet}`)) {
    return true;
  }
  if (analysisTags.includes(`en:maybe-${diet}`)) return null;

  return keywordCompatible;
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

  // "May contain" — a weaker, separate signal. Kept distinct from confirmed
  // allergens so the UI can show "iz içerebilir", never as a confirmed match.
  // A key already confirmed above is not repeated here.
  const traceKeys: string[] = [];
  for (const tag of product.traces_tags ?? []) {
    for (const key of resolveAllergenKeys(String(tag))) {
      if (!productKeySet.has(key) && !traceKeys.includes(key)) {
        traceKeys.push(key);
      }
    }
  }
  const traces = traceKeys.map((key) => ({
    key,
    matched: profileKeys.has(key),
  }));

  // 2. Vegan / Vejetaryen Uyumluluğu
  // OFF's own analysis/labels are authoritative; our keyword lists are only a
  // fallback when OFF has no diet tag at all.
  const ingredients = (product.ingredients_text || "").toLowerCase();
  const allergensTags = product.allergens_tags || [];
  const analysisTags: string[] = (product.ingredients_analysis_tags ?? [])
    .map((t: string) => String(t).toLowerCase());
  const labelsTags: string[] = (product.labels_tags ?? [])
    .map((t: string) => String(t).toLowerCase());

  // "et" alone would match "petit"/"beta"; meat is caught via explicit forms.
  const nonVeganKeywords = [
    "süt", "milk", "peynir", "cheese", "yoğurt", "yogurt", "tereyağı", "butter",
    "yumurta", "egg", "bal", "honey", "meat", "tavuk", "chicken", "hindi",
    "dana", "kuzu", "domuz", "sosis", "salam", "sucuk", "jambon", "kıyma",
    "biftek", "balık", "fish", "karides", "jelatin", "gelatin",
  ];
  const hasNonVeganIngredient = nonVeganKeywords.some((k) =>
    ingredients.includes(k)
  );
  const hasNonVeganAllergen = allergensTags.some((tag: string) =>
    ["milk", "egg", "fish", "meat"].some((t) => tag.toLowerCase().includes(t))
  );
  const keywordVegan = !hasNonVeganIngredient && !hasNonVeganAllergen;

  const isVeganCompatible = resolveDietCompatibility(
    "vegan",
    analysisTags,
    labelsTags,
    dataSufficiency,
    keywordVegan,
  );

  // Vejetaryen: yalnızca et/balık/jelatin dışlanır; süt ve yumurta serbesttir.
  const nonVegetarianKeywords = [
    "et suyu", "kırmızı et", "dana eti", "kuzu eti", "tavuk eti", "hindi eti",
    "sığır eti", "meat", "tavuk", "chicken", "hindi", "dana", "kuzu", "domuz",
    "sosis", "salam", "sucuk", "jambon", "kıyma", "biftek", "balık", "fish",
    "karides", "jelatin", "gelatin",
  ];
  const hasNonVegetarianIngredient = nonVegetarianKeywords.some((k) =>
    ingredients.includes(k)
  );
  const hasNonVegetarianAllergen = allergensTags.some((tag: string) =>
    ["fish", "meat", "crustaceans"].some((t) => tag.toLowerCase().includes(t))
  );
  const keywordVegetarian = !hasNonVegetarianIngredient &&
    !hasNonVegetarianAllergen;

  const isVegetarianCompatible = resolveDietCompatibility(
    "vegetarian",
    analysisTags,
    labelsTags,
    dataSufficiency,
    keywordVegetarian,
  );

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

  // 2.6 Sözlük tabanlı diyetler (glutensiz / ketojenik / düşük karbonhidrat).
  const rawDiets = profile?.diet_preference;
  const dietInputs: string[] = (Array.isArray(rawDiets)
    ? rawDiets
    : rawDiets == null
    ? []
    : [rawDiets])
    .map((diet: unknown) => String(diet ?? "").trim())
    .filter((diet: string) => diet.length > 0);

  const dietConditions = dietInputs
    .map((diet) => ({
      diet,
      status: evaluateDietImplication(
        diet,
        productKeySet,
        product.nutriments,
        dataSufficiency,
      ),
    }))
    // Only diets this dictionary actually knows; the rest keep their own logic.
    .filter((d) => dietImplication(d.diet) !== null);

  const hasDietConflict = dietConditions.some((d) => d.status === "conflict");

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
  // matches, diet conflicts (vegan/vegetarian/athlete/diabetic/dictionary) and
  // health conditions.
  const hasConflict = matched.length > 0 ||
    hasVeganConflict ||
    hasVegetarianConflict ||
    hasAthleteConflict ||
    hasDiabeticDietConflict ||
    hasDietConflict ||
    hasHealthConflict;

  return {
    matched_allergens: matched,
    allergens,
    // "May contain" allergens; weaker than `allergens`. Not folded into
    // has_conflict — surfaced separately as a caution, not a confirmed verdict.
    traces,
    // Per health condition: "conflict" | "ok" | "not_evaluated". Consumers must
    // treat "not_evaluated" as "kontrol edilemedi", never as safe.
    health_conditions: healthConditions,
    // Dictionary-driven diets (glutensiz / ketojenik / düşük karbonhidrat),
    // same status vocabulary as health_conditions.
    diet_conditions: dietConditions,
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
