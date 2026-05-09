-- ════════════════════════════════════════════════════════════════════════
-- NeoAgora Landing — Kayıt Tablosu (registrations)
--
-- Bu SQL'i Supabase Dashboard → SQL Editor'da bir kez çalıştır.
-- Mevcut neoagora-app projesinin Supabase projesinin aynısına gidiyoruz —
-- yeni proje oluşturmaya gerek yok.
--
-- TABLO: public.registrations
-- RLS:   anon kullanıcılar SADECE INSERT yapabilir, hiçbir şey okuyamaz.
--        Sen (admin/owner) her şeyi görebilir/düzenleyebilirsin.
-- ════════════════════════════════════════════════════════════════════════

-- 1) Tablo
create table if not exists public.registrations (
  id              uuid primary key default gen_random_uuid(),
  full_name       text not null check (length(full_name) between 2 and 80),
  email           text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  phone           text not null check (length(phone) between 7 and 25),
  age             integer not null check (age between 12 and 99),
  school          text not null check (length(school) between 2 and 80),
  format_preference text not null check (format_preference in ('online', 'fiziksel', 'farketmez')),
  notes           text check (notes is null or length(notes) <= 500),
  status          text not null default 'pending' check (status in ('pending', 'confirmed', 'cancelled', 'waitlist')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  -- Aynı e-posta iki kez kayıt olamasın (form sayfasında da uyarı veriyoruz)
  constraint registrations_email_unique unique (email)
);

-- Hızlı arama için index
create index if not exists registrations_email_idx on public.registrations (email);
create index if not exists registrations_created_at_idx on public.registrations (created_at desc);
create index if not exists registrations_status_idx on public.registrations (status);

-- 2) updated_at otomatik güncellensin
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists registrations_touch_updated_at on public.registrations;
create trigger registrations_touch_updated_at
  before update on public.registrations
  for each row execute function public.touch_updated_at();

-- 3) Row-Level Security AÇ
alter table public.registrations enable row level security;

-- 4) Politikalar
-- 4a) Anonim kullanıcı (landing form'undan gelen) sadece INSERT yapabilir.
--     Hiçbir şekilde başkalarının kayıtlarını okuyamaz, güncelleyemez.
drop policy if exists "Anonim kayıt ekleyebilir" on public.registrations;
create policy "Anonim kayıt ekleyebilir"
  on public.registrations
  for insert
  to anon
  with check (true);

-- 4b) Authenticated kullanıcı kendi e-posta adresine ait kayıtları görebilir.
--     (İleride "kayıt durumumu sorgula" özelliği eklersen kullanırsın.)
drop policy if exists "Kayıt sahibi kendi kaydını görebilir" on public.registrations;
create policy "Kayıt sahibi kendi kaydını görebilir"
  on public.registrations
  for select
  to authenticated
  using (auth.jwt() ->> 'email' = email);

-- NOT: SUPER USER / SERVICE_ROLE her zaman tüm RLS'leri bypass eder.
--      Yani Supabase Dashboard'tan tüm kayıtları görebilirsin (Table Editor).
--      Bir admin paneli yapacaksan service_role key kullan.

-- ════════════════════════════════════════════════════════════════════════
-- TEST — Bu SQL'i ekledikten sonra terminalden / browser'dan deneyebilirsin:
--
-- insert into public.registrations
--   (full_name, email, phone, age, school, format_preference)
-- values
--   ('Test Kayıt', 'test@example.com', '05551234567', 25, 'Test Üniv.', 'online');
--
-- select count(*) from public.registrations;  -- Service role: 1, anon: 0
-- ════════════════════════════════════════════════════════════════════════
