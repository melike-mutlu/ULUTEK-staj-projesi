// TODO (Backend pod): diyet tercihine göre gerçek diet_flags mantığı (vegan/diyabet) genişletilecek.
export function runRuleEngine(product: any, profile: any) {
  const userAllergies: string[] = profile?.allergies ?? [];
  const matched = userAllergies.filter((allergy) =>
    (product.allergens_tags ?? []).some((tag: string) =>
      tag.toLowerCase().includes(allergy.toLowerCase())
    )
  );

  return {
    matched_allergens: matched,
    has_conflict: matched.length > 0,
    diet_flags: {
      vegan_compatible: true, // TODO
      diabetic_note: null, // TODO
    },
  };
}

export function findMissingFields(product: any) {
  const missing: string[] = [];
  const n = product.nutriments;
  if (!n || Object.values(n).every((v) => v == null)) missing.push("nutriments");
  return missing;
}