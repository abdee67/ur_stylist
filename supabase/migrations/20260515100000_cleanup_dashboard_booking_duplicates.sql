-- Remove dashboard columns that duplicated the existing booking schema.
-- Canonical bookings use:
--   customer -> public.customers(id)
--   stylist -> public.stylists(id)
--   address -> public.customer_addresses(id)
--   booking_services -> per-service booking rows
--   commission_amount / stylist_earning -> booking financial split

drop policy if exists stylist_sees_own_bookings on public.bookings;
drop policy if exists stylist_updates_own_bookings on public.bookings;

alter table public.bookings
  drop constraint if exists bookings_client_id_fkey,
  drop constraint if exists bookings_service_id_fkey,
  drop constraint if exists bookings_stylist_id_fkey;

alter table public.bookings
  drop column if exists client_id,
  drop column if exists stylist_id,
  drop column if exists service_id,
  drop column if exists latitude,
  drop column if exists longitude,
  drop column if exists platform_fee,
  drop column if exists stylist_earnings;

create policy stylist_sees_own_bookings on public.bookings
  for select using (
    stylist in (select id from public.stylists where user_id = auth.uid())
  );

create policy stylist_updates_own_bookings on public.bookings
  for update using (
    stylist in (select id from public.stylists where user_id = auth.uid())
  )
  with check (
    stylist in (select id from public.stylists where user_id = auth.uid())
    and status in ('confirmed', 'in_progress', 'completed', 'cancelled')
    and coalesce(cancelled_by, 'stylist') <> 'client'
  );
