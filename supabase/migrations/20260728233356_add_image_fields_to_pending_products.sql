alter table pending_products
  add column IF NOT EXISTS image_front_url text,
  add column IF NOT EXISTS image_ingredients_url text,
  add column IF NOT EXISTS image_nutrition_url text;