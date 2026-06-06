-- Keep stylist completion, wallet settlement, and review aggregates server-side.

create or replace function public.complete_stylist_booking(p_booking_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth_user uuid := auth.uid();
  v_stylist_id uuid;
  v_booking public.bookings%rowtype;
  v_payment public.payments%rowtype;
  v_amount numeric(10, 2);
  v_wallet_result jsonb;
begin
  if v_auth_user is null then
    raise exception 'Please sign in again.';
  end if;

  select id
  into v_stylist_id
  from public.stylists
  where user_id = v_auth_user;

  if v_stylist_id is null then
    raise exception 'Stylist profile not found.';
  end if;

  select *
  into v_booking
  from public.bookings
  where id = p_booking_id
    and stylist = v_stylist_id
  for update;

  if not found then
    raise exception 'Booking not found.';
  end if;

  if v_booking.status not in ('confirmed', 'in_progress', 'completed') then
    raise exception 'Only active bookings can be completed.';
  end if;

  select *
  into v_payment
  from public.payments
  where booking_id = p_booking_id
    and payment_type = 'payment'
    and status = 'succeeded'
  order by paid_at desc nulls last, created_at desc
  limit 1;

  if not found then
    raise exception 'Customer payment must be completed before wallet settlement.';
  end if;

  v_amount := coalesce(nullif(v_booking.stylist_earning::numeric, 0), 0);
  if v_amount <= 0 then
    v_amount := greatest(
      coalesce(v_booking.total_amount, 0) - coalesce(v_booking.commission_amount::numeric, 0),
      0
    );
  end if;

  if v_amount <= 0 then
    raise exception 'Stylist earning amount is missing for this booking.';
  end if;

  update public.bookings
  set
    status = 'completed',
    completed_at = coalesce(completed_at, timezone('utc', now())),
    updated_at = timezone('utc', now())
  where id = p_booking_id;

  select public.credit_stylist_wallet(
    p_stylist_id => v_stylist_id,
    p_booking_id => p_booking_id,
    p_payment_id => v_payment.id,
    p_amount => v_amount,
    p_currency => v_payment.currency,
    p_source => 'booking_earning',
    p_reference => v_payment.transaction_reference,
    p_metadata => jsonb_build_object(
      'settled_by', 'complete_stylist_booking',
      'payment_status', v_payment.status,
      'payment_method', v_payment.payment_method
    )
  )
  into v_wallet_result;

  return jsonb_build_object(
    'booking_id', p_booking_id,
    'payment_id', v_payment.id,
    'amount', v_amount,
    'wallet', v_wallet_result
  );
end;
$$;

revoke all on function public.complete_stylist_booking(uuid) from public;
grant execute on function public.complete_stylist_booking(uuid) to authenticated;

create or replace function public.refresh_stylist_review_summary(p_stylist_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.stylists s
  set
    avg_rating = coalesce(stats.avg_rating, 0),
    total_reviews = coalesce(stats.total_reviews, 0),
    updated_at = timezone('utc', now())
  from (
    select
      p_stylist_id as stylist_id,
      round(avg(r.rating)::numeric, 2) as avg_rating,
      count(*)::integer as total_reviews
    from public.reviews r
    where r.stylists_id = p_stylist_id
  ) stats
  where s.id = p_stylist_id;
end;
$$;

revoke all on function public.refresh_stylist_review_summary(uuid) from public;

create or replace function public.handle_review_aggregate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_stylist_id uuid;
  v_booking_id uuid;
begin
  v_stylist_id := coalesce(new.stylists_id, old.stylists_id);
  v_booking_id := coalesce(new.booking_id, old.booking_id);

  if v_booking_id is not null and tg_op <> 'DELETE' then
    update public.bookings
    set
      is_reviewed = true,
      updated_at = timezone('utc', now())
    where id = v_booking_id;
  end if;

  if v_stylist_id is not null then
    perform public.refresh_stylist_review_summary(v_stylist_id);
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_reviews_refresh_stylist_summary on public.reviews;
create trigger trg_reviews_refresh_stylist_summary
after insert or update or delete on public.reviews
for each row execute function public.handle_review_aggregate();

create or replace function public.submit_booking_review(
  p_booking_id uuid,
  p_rating double precision,
  p_comment text default null
)
returns public.reviews
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth_user uuid := auth.uid();
  v_customer_id uuid;
  v_booking public.bookings%rowtype;
  v_review public.reviews%rowtype;
begin
  if v_auth_user is null then
    raise exception 'Please sign in again.';
  end if;

  if p_rating < 1 or p_rating > 5 then
    raise exception 'Rating must be between 1 and 5.';
  end if;

  select id
  into v_customer_id
  from public.customers
  where id = v_auth_user;

  if v_customer_id is null then
    raise exception 'Customer profile not found.';
  end if;

  select *
  into v_booking
  from public.bookings
  where id = p_booking_id
    and customer = v_customer_id
  for update;

  if not found then
    raise exception 'Booking not found.';
  end if;

  if v_booking.status <> 'completed' then
    raise exception 'Only completed bookings can be reviewed.';
  end if;

  insert into public.reviews (
    booking_id,
    customer_id,
    stylists_id,
    rating,
    comment
  )
  values (
    p_booking_id,
    v_customer_id,
    v_booking.stylist,
    p_rating,
    nullif(trim(p_comment), '')
  )
  on conflict (booking_id)
  do update set
    rating = excluded.rating,
    comment = excluded.comment,
    created_at = timezone('utc', now())
  returning *
  into v_review;

  return v_review;
end;
$$;

revoke all on function public.submit_booking_review(uuid, double precision, text)
  from public;
grant execute on function public.submit_booking_review(uuid, double precision, text)
  to authenticated;

-- Repair rows created by the previous client-side completion path: those rows
-- could exist without payment/reference metadata while wallet.balance stayed low.
with booking_earning_totals as (
  select
    wt.wallet_id,
    sum(wt.amount) filter (
      where wt.transaction_type = 'credit'
        and wt.source = 'booking_earning'
    ) -
    coalesce(sum(wt.amount) filter (
      where wt.transaction_type = 'debit'
        and wt.source in ('withdrawal', 'penalty')
    ), 0) as computed_balance
  from public.wallet_transactions wt
  group by wt.wallet_id
)
update public.wallets w
set
  balance = greatest(w.balance, coalesce(t.computed_balance, 0)),
  updated_at = timezone('utc', now())
from booking_earning_totals t
where t.wallet_id = w.id
  and coalesce(t.computed_balance, 0) > w.balance;

update public.wallet_transactions wt
set metadata = coalesce(wt.metadata, '{}'::jsonb) || jsonb_build_object(
  'reconciled_by', '20260606100000_fix_stylist_settlement_reviews'
)
where wt.source = 'booking_earning'
  and wt.payment_id is null
  and not (coalesce(wt.metadata, '{}'::jsonb) ? 'reconciled_by');

update public.wallet_transactions wt
set
  payment_id = p.id,
  reference = p.transaction_reference,
  metadata = coalesce(wt.metadata, '{}'::jsonb) || jsonb_build_object(
    'payment_status', p.status,
    'payment_method', p.payment_method
  )
from public.payments p
where wt.booking_id = p.booking_id
  and wt.source = 'booking_earning'
  and wt.transaction_type = 'credit'
  and wt.payment_id is null
  and p.payment_type = 'payment'
  and p.status = 'succeeded';
