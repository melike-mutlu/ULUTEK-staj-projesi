alter table product_cache
  add column if not exists traces_tags text[],
  add column if not exists ingredients_analysis_tags text[],
  add column if not exists labels_tags text[];
