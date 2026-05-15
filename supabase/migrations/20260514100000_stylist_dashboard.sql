-- Post-approval stylist dashboard support.

create table if not exists public.bookings (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references public.users(id),
  stylist_id uuid references public.stylists(id),
  service_id uuid references public.services(id),
  status text not null default 'pending',
  scheduled_at timestamptz not null,
  address text not null,
  latitude numeric(10, 8),
  longitude numeric(11, 8),
  total_amount numeric(10, 2) not null default 0,
  platform_fee numeric(10, 2) not null default 0,
  stylist_earnings numeric(10, 2) not null default 0,
  notes text,
  cancelled_by text,
  cancellation_reason text,
  accept_deadline timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.bookings
  add column if not exists client_id uuid references public.users(id),
  add column if not exists stylist_id uuid references public.stylists(id),
  add column if not exists service_id uuid references public.services(id),
  add column if not exists address text,
  add column if not exists latitude numeric(10, 8),
  add column if not exists longitude numeric(11, 8),
  add column if not exists platform_fee numeric(10, 2) default 0 not null,
  add column if not exists stylist_earnings numeric(10, 2) default 0 not null,
  add column if not exists notes text,
  add column if not exists cancelled_by text,
  add column if not exists cancellation_reason text,
  add column if not exists accept_deadline timestamptz,
  add column if not exists started_at timestamptz,
  add column if not exists completed_at timestamptz,
  add column if not exists cancelled_at timestamptz;

alter table public.bookings
  drop constraint if exists bookings_status_check;

alter table public.bookings
  drop constraint if exists bookings_dashboard_status_check;

alter table public.bookings
  add constraint bookings_status_check
  check (status in (
    'pending', 'confirmed', 'in_progress',
    'completed', 'cancelled', 'missed',
    'rescheduled', 'no_show'
  ));

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'bookings_cancelled_by_check'
  ) then
    alter table public.bookings
      add constraint bookings_cancelled_by_check
      check (cancelled_by is null or cancelled_by in ('client', 'stylist', 'system'));
  end if;
end $$;

alter table public.wallets
  add column if not exists security_deposit numeric(10, 2) default 0 not null,
  add column if not exists minimum_deposit numeric(10, 2) default 500 not null,
  add column if not exists deposit_verified boolean default false,
  add column if not exists is_active boolean default false;

alter table public.stylists
  add column if not exists preferences jsonb default '{}'::jsonb not null;

alter table public.stylists
  drop constraint if exists stylists_onboarding_status_check;

alter table public.stylists
  add constraint stylists_onboarding_status_check
  check (onboarding_status in (
    'basic_info', 'email_verified', 'kyc_submitted',
    'professional_submitted', 'wallet_done',
    'pending_review', 'approved', 'rejected',
    'suspended'
  ));

create table if not exists public.wallet_transactions (
  id uuid default gen_random_uuid() primary key,
  wallet_id uuid not null references public.wallets(id),
  booking_id uuid references public.bookings(id),
  payment_id uuid,
  transaction_type text not null check (transaction_type in ('credit', 'debit')),
  amount numeric(10, 2) not null check (amount > 0),
  source text not null check (source in ('booking_earning', 'penalty', 'withdrawal', 'topup')),
  reference text,
  metadata jsonb default '{}'::jsonb not null,
  created_at timestamptz default timezone('utc', now()) not null
);

create table if not exists public.payouts (
  id uuid default gen_random_uuid() primary key,
  wallet_id uuid not null references public.wallets(id),
  amount numeric(10, 2) not null,
  payout_method text not null default 'bank_transfer',
  status text not null default 'pending'
    check (status in ('pending', 'processing', 'paid', 'failed', 'cancelled')),
  metadata jsonb default '{}'::jsonb not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create or replace function public.activate_stylist_on_deposit()
returns trigger as $$
begin
  if new.deposit_verified = true and old.deposit_verified = false then
    update public.stylists
    set is_verified = true
    where id = new.stylist_id;
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_activate_on_deposit on public.wallets;
create trigger trg_activate_on_deposit
  after update on public.wallets
  for each row execute function public.activate_stylist_on_deposit();

create or replace function public.set_accept_deadline()
returns trigger as $$
begin
  if new.accept_deadline is null then
    new.accept_deadline := now() + interval '15 minutes';
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_booking_deadline on public.bookings;
create trigger trg_booking_deadline
  before insert on public.bookings
  for each row execute function public.set_accept_deadline();

create or replace function public.expire_pending_bookings()
returns void as $$
begin
  update public.bookings
  set status = 'missed', cancelled_by = 'system', updated_at = now()
  where status = 'pending'
    and accept_deadline < now();
end;
$$ language plpgsql;

alter table public.bookings enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.payouts enable row level security;

drop policy if exists stylist_sees_own_bookings on public.bookings;
create policy stylist_sees_own_bookings on public.bookings
  for select using (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  );

drop policy if exists stylist_updates_own_bookings on public.bookings;
create policy stylist_updates_own_bookings on public.bookings
  for update using (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylist_id in (select id from public.stylists where user_id = auth.uid())
    and status in ('confirmed', 'in_progress', 'completed', 'cancelled')
    and coalesce(cancelled_by, 'stylist') <> 'client'
  );

drop policy if exists stylist_wallet_transactions_self on public.wallet_transactions;
create policy stylist_wallet_transactions_self on public.wallet_transactions
  for all using (
    wallet_id in (
      select w.id
      from public.wallets w
      join public.stylists s on s.id = w.stylist_id
      where s.user_id = auth.uid()
    )
  )
  with check (
    wallet_id in (
      select w.id
      from public.wallets w
      join public.stylists s on s.id = w.stylist_id
      where s.user_id = auth.uid()
    )
  );

drop policy if exists stylist_payouts_self on public.payouts;
create policy stylist_payouts_self on public.payouts
  for all using (
    wallet_id in (
      select w.id
      from public.wallets w
      join public.stylists s on s.id = w.stylist_id
      where s.user_id = auth.uid()
    )
  )
  with check (
    wallet_id in (
      select w.id
      from public.wallets w
      join public.stylists s on s.id = w.stylist_id
      where s.user_id = auth.uid()
    )
  );

insert into storage.buckets (id, name, public)
values ('deposit-proofs', 'deposit-proofs', false)
on conflict (id) do update set public = excluded.public;

drop policy if exists stylist_deposit_proof_upload on storage.objects;
create policy stylist_deposit_proof_upload on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'deposit-proofs'
    and (storage.foldername(name))[1] in (
      select id::text from public.stylists where user_id = auth.uid()
    )
  );

drop policy if exists stylist_deposit_proof_read on storage.objects;
create policy stylist_deposit_proof_read on storage.objects
  for select to authenticated
  using (
    bucket_id = 'deposit-proofs'
    and (storage.foldername(name))[1] in (
      select id::text from public.stylists where user_id = auth.uid()
    )
  );
