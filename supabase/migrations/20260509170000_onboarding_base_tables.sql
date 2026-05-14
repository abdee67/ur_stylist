-- Minimal base tables required by the stylist onboarding flow.
-- The full production schema is still tracked in schema.sql; this migration lets
-- a fresh local Supabase stack start before the onboarding migration runs.

create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists "pgcrypto" with schema extensions;

create table if not exists public.users (
  id uuid default auth.uid() not null primary key,
  created_at timestamptz default now() not null,
  email text not null,
  phone text not null,
  name text not null
);

create table if not exists public.services (
  id uuid default extensions.uuid_generate_v4() not null primary key,
  name text not null,
  description text,
  category_id uuid,
  duration_minutes integer not null,
  base_price numeric(10, 2) not null,
  min_price numeric(10, 2),
  is_active boolean default true,
  icon_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.stylists (
  id uuid default extensions.uuid_generate_v4() not null primary key,
  business_name text not null,
  description text,
  service_radius_km integer default 10,
  is_verified boolean default false,
  avg_rating numeric(3, 2) default 0.0,
  total_reviews integer default 0,
  latitude numeric(10, 8),
  longitude numeric(11, 8),
  image_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.stylists_availability (
  id uuid default extensions.uuid_generate_v4() not null primary key,
  stylists_id uuid not null references public.stylists(id),
  day_of_week text not null,
  start_time time not null,
  end_time time not null,
  is_available boolean default true
);

create table if not exists public.stylists_services (
  id uuid default extensions.uuid_generate_v4() not null primary key,
  stylists_id uuid not null references public.stylists(id),
  service_id uuid not null references public.services(id),
  price numeric(10, 2) not null,
  is_available boolean default true
);

create table if not exists public.wallets (
  id uuid default extensions.gen_random_uuid() primary key,
  stylist_id uuid not null references public.stylists(id),
  balance numeric(10, 2) default 0 not null,
  currency text default 'etb' not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
