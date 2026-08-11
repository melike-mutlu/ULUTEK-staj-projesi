alter table product_cache
  add column if not exists brand text,
  add column if not exists categories_tags text[];
