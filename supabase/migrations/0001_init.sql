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

-- ---------------------------------------------------------------------------
-- pending_products: OFF'ta bulunamayan veya manuel eklenen ürünler
-- ---------------------------------------------------------------------------
create table pending_products (
  id uuid primary key default gen_random_uuid(),
  barcode text not null,
  user_id uuid references auth.users(id) on delete cascade,
  product_name text,
  ingredients_text text,
  status text not null default 'PENDING' check (status in ('PENDING', 'APPROVED', 'REJECTED')),
  created_at timestamptz not null default now(),
  constraint pending_products_user_id_barcode_key unique (user_id, barcode)
);

create index idx_pending_products_user_id on pending_products (user_id);
create index idx_pending_products_barcode on pending_products (barcode);

alter table pending_products enable row level security;

create policy "Kullanıcı kendi eklediği askıdaki ürünleri okuyabilir"
  on pending_products for select
  using (auth.uid() = user_id);

create policy "Kullanıcı yeni askıda ürün talebi oluşturabilir"
  on pending_products for insert
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- scan_history: Kullanıcıların barkod tarama geçmişi
-- ---------------------------------------------------------------------------
create table scan_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  barcode text not null,
  scanned_at timestamptz not null default now()
);

create index idx_scan_history_user_id_scanned_at on scan_history (user_id, scanned_at desc);

alter table scan_history enable row level security;

create policy "Kullanıcı kendi tarama geçmişini okuyabilir"
  on scan_history for select
  using (auth.uid() = user_id);

create policy "Kullanıcı tarama geçmişi ekleyebilir"
  on scan_history for insert
  with check (auth.uid() = user_id);