-- Bu migration, canlı veritabanında zaten elle uygulanmış ama repoda hiçbir
-- migration dosyasına yazılmamış şema değişikliklerini belgeler (şema kayması
-- giderme). Amaç: bu repodan sıfırdan kurulum yapan biri de aynı şemaya
-- ulaşsın.
--
-- Değişiklikler:
--   1) diet_preference: tekil enum -> çoklu seçime izin veren text[]
--      ('standard' = "özel tercih yok" demekti, boş diziye çevrilir)
--   2) profiles.display_name (nullable) eklendi
--   3) profiles.avatar_url (nullable) eklendi

alter table profiles
  alter column diet_preference drop default;

alter table profiles
  alter column diet_preference type text[]
  using case
    when diet_preference::text = 'standard' then '{}'::text[]
    else array[diet_preference::text]
  end;

alter table profiles
  alter column diet_preference set default '{}';

alter table profiles
  alter column diet_preference set not null;

drop type if exists diet_preference;

alter table profiles
  add column if not exists display_name text;

alter table profiles
  add column if not exists avatar_url text;
