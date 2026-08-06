alter table product_cache
  add column traces_tags text[],
  add column ingredients_analysis_tags text[],
  add column labels_tags text[];