-- Akıllı Sepet — başlangıç şeması
-- bkz. docs/architecture.md

create type diet_preference as enum (
  'standard', 'vegan', 'vejetaryen', 'diyabet_dostu', 'sporcu'
);

-- ---------------------------------------------------------------------------
-- profiles: onboarding'de oluşturulan kullanıcı profili
-- ---------------------------------------------------------------------------
create table profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  allergies text[] not null default '{}',
  diet_preference diet_preference not null default 'standard',
  health_conditions text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "Kullanıcı kendi profilini okuyabilir"
  on profiles for select
  using (auth.uid() = user_id);

create policy "Kullanıcı kendi profilini oluşturabilir"
  on profiles for insert
  with check (auth.uid() = user_id);

create policy "Kullanıcı kendi profilini güncelleyebilir"
  on profiles for update
  using (auth.uid() = user_id);

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
  before update on profiles
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- product_cache: Open Food Facts'ten çekilen ürün verisinin cache'i
-- (yazma yalnızca fetch-product Edge Function'ı üzerinden, service role ile)
-- ---------------------------------------------------------------------------
create table product_cache (
  barcode text primary key,
  name text not null,
  ingredients_text text,
  additives text[] not null default '{}',
  allergens_tags text[] not null default '{}',
  nutriments jsonb,
  nutriscore text,
  fetched_at timestamptz not null default now()
);

alter table product_cache enable row level security;

create policy "Herkes ürün cache'ini okuyabilir"
  on product_cache for select
  using (true);
