-- pending_products: herkes okuyabilsin (onay/oylama için gerekli)
drop policy "Kullanıcı kendi eklediği askıdaki ürünleri okuyabilir" on pending_products;

create policy "Giriş yapan herkes askıdaki ürünleri okuyabilir"

  on pending_products for select

  using (auth.uid() is not null);

  -- ---------------------------------------------------------------------------
-- pending_product_votes: kullanıcıların askıdaki ürünlere onay/red oyu
-- ---------------------------------------------------------------------------
create table pending_product_votes (
  id uuid primary key default gen_random_uuid(),
  pending_product_id uuid not null references pending_products(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  is_approve boolean not null,
  created_at timestamptz not null default now(),
  unique (pending_product_id, user_id)
);

create index idx_pending_product_votes_product_id on pending_product_votes (pending_product_id);

alter table pending_product_votes enable row level security;

create policy "Giriş yapan herkes oyları okuyabilir"
  on pending_product_votes for select
  using (auth.uid() is not null);

create policy "Kullanıcı kendi oyunu oluşturabilir"
  on pending_product_votes for insert
  with check (auth.uid() = user_id);

create policy "Kullanıcı kendi oyunu güncelleyebilir"
  on pending_product_votes for update
  using (auth.uid() = user_id);

  -- pending_product_votes için oy sayısı sorgusu (Ahmet'in mobil tarafı kullanacak)
create or replace function get_pending_product_vote_counts(p_pending_product_id uuid)
returns table(approve_count bigint, reject_count bigint) as $$
  select
    count(*) filter (where is_approve = true) as approve_count,
    count(*) filter (where is_approve = false) as reject_count
  from pending_product_votes
  where pending_product_id = p_pending_product_id;
$$ language sql stable;