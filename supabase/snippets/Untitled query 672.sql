alter table public.product_cache
add column if not exists image_url text,
add column if not exists ingredients_analysis_tags text[],
add column if not exists labels_tags text[],
add column if not exists categories_tags text[],
add column if not exists traces_tags text[];