-- profiles tablosuna country sütununun eklenmesi
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS country text;
