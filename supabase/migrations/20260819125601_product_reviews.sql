-- ---------------------------------------------------------------------------
-- product_reviews: kullanıcıların ürünlere yaptığı yorum ve puanlamalar
-- ---------------------------------------------------------------------------

create table product_reviews (
  id uuid primary key default gen_random_uuid(),
  product_barcode text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating smallint not null check (rating >= 1 and rating <= 5),
  comment text not null check (char_length(trim(comment)) > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique (product_barcode, user_id)
);

-- Ürün yorumlarını barkoda göre hızlı sorgulamak için
create index idx_product_reviews_barcode
  on product_reviews (product_barcode);

-- Kullanıcının kendi yorumlarını hızlı sorgulamak için
create index idx_product_reviews_user_id
  on product_reviews (user_id);

-- ---------------------------------------------------------------------------
-- updated_at: yorum güncellendiğinde otomatik olarak tarihi yenile
-- ---------------------------------------------------------------------------

create or replace function update_product_reviews_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_product_reviews_updated_at
before update on product_reviews
for each row
execute function update_product_reviews_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table product_reviews enable row level security;

-- Herkes ürün yorumlarını okuyabilir
create policy "Herkes yorumları okuyabilir"
  on product_reviews for select
  using (true);

-- Giriş yapmış kullanıcı kendi yorumunu oluşturabilir
create policy "Kullanıcı kendi yorumunu oluşturabilir"
  on product_reviews for insert
  with check (auth.uid() = user_id);

-- Kullanıcı sadece kendi yorumunu güncelleyebilir
create policy "Kullanıcı kendi yorumunu güncelleyebilir"
  on product_reviews for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Kullanıcı sadece kendi yorumunu silebilir
create policy "Kullanıcı kendi yorumunu silebilir"
  on product_reviews for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Mobil taraf için ortalama puan ve toplam yorum sayısı fonksiyonu
-- ---------------------------------------------------------------------------

create or replace function get_product_review_stats(p_product_barcode text)
returns table(
  total_reviews bigint,
  average_rating numeric
) as $$
  select
    count(*) as total_reviews,
    round(coalesce(avg(rating), 0), 1) as average_rating
  from product_reviews
  where product_barcode = p_product_barcode;
$$ language sql stable;