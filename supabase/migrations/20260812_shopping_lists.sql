-- Shopping lists
create table if not exists public.shopping_lists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Shopping list items
-- Sutunlar apps/mobile/lib/core/models/shopping_list.dart'taki
-- ShoppingListItem.toJson()/fromJson() sozlesmesiyle birebir eslesir.
create table if not exists public.shopping_list_items (
  id uuid primary key default gen_random_uuid(),
  list_id uuid not null references public.shopping_lists(id) on delete cascade,
  product_name text not null,
  barcode text,
  brand text,
  image_url text,
  is_bought boolean not null default false,
  quantity integer not null default 1,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_shopping_lists_user
  on public.shopping_lists(user_id);

-- Liste ürünlerini eklenme sırasına göre hızlı getirmek için
create index if not exists idx_shopping_list_items_list_created
  on public.shopping_list_items(list_id, created_at desc);

-- RLS
alter table public.shopping_lists enable row level security;
alter table public.shopping_list_items enable row level security;

-- shopping_lists policies
create policy "shopping_lists_select_own"
on public.shopping_lists
for select
using (auth.uid() = user_id);

create policy "shopping_lists_insert_own"
on public.shopping_lists
for insert
with check (auth.uid() = user_id);

create policy "shopping_lists_update_own"
on public.shopping_lists
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "shopping_lists_delete_own"
on public.shopping_lists
for delete
using (auth.uid() = user_id);

-- shopping_list_items policies
create policy "shopping_list_items_select_own"
on public.shopping_list_items
for select
using (
  exists (
    select 1
    from public.shopping_lists l
    where l.id = shopping_list_items.list_id
      and l.user_id = auth.uid()
  )
);

create policy "shopping_list_items_insert_own"
on public.shopping_list_items
for insert
with check (
  exists (
    select 1
    from public.shopping_lists l
    where l.id = shopping_list_items.list_id
      and l.user_id = auth.uid()
  )
);

create policy "shopping_list_items_update_own"
on public.shopping_list_items
for update
using (
  exists (
    select 1
    from public.shopping_lists l
    where l.id = shopping_list_items.list_id
      and l.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.shopping_lists l
    where l.id = shopping_list_items.list_id
      and l.user_id = auth.uid()
  )
);

create policy "shopping_list_items_delete_own"
on public.shopping_list_items
for delete
using (
  exists (
    select 1
    from public.shopping_lists l
    where l.id = shopping_list_items.list_id
      and l.user_id = auth.uid()
  )
);