-- GUVENLIK: chat_history icin iki farkli migration var (20260731 RLS'li,
-- 20260806233000 RLS'siz), ikisi de "CREATE TABLE IF NOT EXISTS" kullaniyor.
-- Hangisinin canli veritabaninda "kazandigini" migration dosyalarindan tespit
-- edemiyoruz - eger 20260806233000 sekli kazandiysa, chat_history su an HICBIR
-- RLS korumasi olmadan duruyor demektir: herhangi bir giris yapmis kullanici
-- baskasinin sohbet gecmisini (saglik/alerji konusmalari dahil) okuyabilir.
--
-- Bu migration hangi sekil canli olursa olsun RLS'i ve policy'leri garanti eder.
-- Idempotent: zaten dogru kuruluysa hicbir sey degismez.

alter table if exists public.chat_history enable row level security;

drop policy if exists "Users can view their own chat history" on public.chat_history;
create policy "Users can view their own chat history"
  on public.chat_history for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own chat history" on public.chat_history;
create policy "Users can insert their own chat history"
  on public.chat_history for insert
  with check (auth.uid() = user_id);
