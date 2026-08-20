-- scan_history.had_conflict: taranan urunde profil cakismasi (alerjen/diyet/
-- saglik uyarisi) olup olmadigini kaydeder. Haftalik ozet ekranindaki
-- "kac alerjenden kacindin" istatistigi bunu sayar.
--
-- Mobil taraf (PR #87, Melike Dal) bu kolonu ve asagidaki RPC'yi zaten
-- bekliyordu ama migration hic eklenmemisti - hem tarama kaydi (INSERT'te
-- olmayan kolona yazma hatasi) hem de istatistik RPC'si canlida
-- calismayacakti. Buradan tamamlaniyor.
alter table scan_history
  add column had_conflict boolean not null default false;

-- Belirli bir kullanicinin, verilen tarihten (p_start_date) itibaren kac
-- taramasinda profil cakismasi oldugunu doner. RLS zaten scan_history'yi
-- auth.uid() = user_id ile kisitliyor; p_user_id filtresi bununla birlikte
-- calisir (baska kullanicinin id'si verilse bile RLS 0 satir dondurur).
create or replace function get_user_weekly_monthly_summary(
  p_user_id uuid,
  p_start_date timestamptz
)
returns json as $$
  select json_build_object(
    'conflicts', count(*) filter (where had_conflict = true),
    'total_scans', count(*)
  )
  from scan_history
  where user_id = p_user_id
    and scanned_at >= p_start_date;
$$ language sql stable;
