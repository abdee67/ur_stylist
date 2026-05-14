-- Stylist onboarding support.
-- Run this migration after the base schema has been applied.

alter table public.stylists
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists onboarding_status text default 'basic_info'
    check (onboarding_status in (
      'basic_info', 'email_verified', 'kyc_submitted',
      'professional_submitted', 'wallet_done',
      'pending_review', 'approved', 'rejected'
    )),
  add column if not exists years_experience integer,
  add column if not exists rejection_reason text;

create table if not exists public.stylist_documents (
  id uuid default gen_random_uuid() primary key,
  stylist_id uuid not null references public.stylists(id) on delete cascade,
  type text not null check (type in (
    'national_id_front', 'national_id_back', 'selfie', 'license'
  )),
  file_url text not null,
  verified boolean default false,
  uploaded_at timestamptz default now()
);

create table if not exists public.stylist_payout_accounts (
  id uuid default gen_random_uuid() primary key,
  stylist_id uuid not null references public.stylists(id) on delete cascade,
  account_holder_name text not null,
  bank_name text not null,
  account_number text not null,
  metadata jsonb default '{}'::jsonb not null,
  is_primary boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.stylist_portfolio (
  id uuid default gen_random_uuid() primary key,
  stylist_id uuid not null references public.stylists(id) on delete cascade,
  image_url text not null,
  caption text,
  created_at timestamptz default now()
);

create unique index if not exists stylists_user_id_key
  on public.stylists(user_id)
  where user_id is not null;

create unique index if not exists stylists_services_stylist_service_key
  on public.stylists_services(stylists_id, service_id);

create unique index if not exists stylists_availability_stylist_day_key
  on public.stylists_availability(stylists_id, day_of_week);

create unique index if not exists wallets_stylist_id_key
  on public.wallets(stylist_id);

alter table public.stylists enable row level security;
alter table public.stylist_documents enable row level security;
alter table public.stylist_payout_accounts enable row level security;
alter table public.stylist_portfolio enable row level security;
alter table public.stylists_availability enable row level security;
alter table public.stylists_services enable row level security;
alter table public.wallets enable row level security;

drop policy if exists stylist_self_select on public.stylists;
create policy stylist_self_select on public.stylists
  for select using (user_id = auth.uid());

drop policy if exists stylist_self_insert on public.stylists;
create policy stylist_self_insert on public.stylists
  for insert with check (user_id = auth.uid());

drop policy if exists stylist_self_update on public.stylists;
create policy stylist_self_update on public.stylists
  for update using (user_id = auth.uid())
  with check (user_id = auth.uid() and is_verified = false);

drop policy if exists stylist_documents_self on public.stylist_documents;
create policy stylist_documents_self on public.stylist_documents
  for all using (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists stylist_payout_self on public.stylist_payout_accounts;
create policy stylist_payout_self on public.stylist_payout_accounts
  for all using (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists stylist_portfolio_self on public.stylist_portfolio;
create policy stylist_portfolio_self on public.stylist_portfolio
  for all using (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists stylist_availability_self on public.stylists_availability;
create policy stylist_availability_self on public.stylists_availability
  for all using (
    stylists_id in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylists_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists stylist_services_self on public.stylists_services;
create policy stylist_services_self on public.stylists_services
  for all using (
    stylists_id in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylists_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists wallet_self_select on public.wallets;
create policy wallet_self_select on public.wallets
  for select using (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists wallet_self_insert on public.wallets;
create policy wallet_self_insert on public.wallets
  for insert with check (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  );

insert into storage.buckets (id, name, public)
values
  ('stylist-kyc-docs', 'stylist-kyc-docs', false),
  ('stylist-licenses', 'stylist-licenses', false),
  ('stylist-portfolios', 'stylist-portfolios', true),
  ('stylist-profile-photos', 'stylist-profile-photos', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists stylist_kyc_upload_own_folder on storage.objects;
create policy stylist_kyc_upload_own_folder on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'stylist-kyc-docs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists stylist_license_upload_own_folder on storage.objects;
create policy stylist_license_upload_own_folder on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'stylist-licenses'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists stylist_portfolio_upload_own_folder on storage.objects;
create policy stylist_portfolio_upload_own_folder on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'stylist-portfolios'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists stylist_profile_upload_own_folder on storage.objects;
create policy stylist_profile_upload_own_folder on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'stylist-profile-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists stylist_private_read_own_folder on storage.objects;
create policy stylist_private_read_own_folder on storage.objects
  for select to authenticated
  using (
    bucket_id in ('stylist-kyc-docs', 'stylist-licenses')
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists stylist_public_media_read on storage.objects;
create policy stylist_public_media_read on storage.objects
  for select
  using (bucket_id in ('stylist-portfolios', 'stylist-profile-photos'));

drop policy if exists stylist_storage_update_own_folder on storage.objects;
create policy stylist_storage_update_own_folder on storage.objects
  for update to authenticated
  using (
    bucket_id in (
      'stylist-kyc-docs',
      'stylist-licenses',
      'stylist-portfolios',
      'stylist-profile-photos'
    )
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id in (
      'stylist-kyc-docs',
      'stylist-licenses',
      'stylist-portfolios',
      'stylist-profile-photos'
    )
    and (storage.foldername(name))[1] = auth.uid()::text
  );
