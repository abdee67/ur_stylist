# Stylist App — Dashboards Implementation Prompt

---

## Project Context

Flutter + Supabase app for on-demand beauty services in Ethiopia (ETB currency).
Stylists are already onboarded and approved. This prompt covers the **post-login main app**:
a `BottomNavigationBar` with three tabs — Home, Wallet, Settings.

Tech stack: Flutter, Bloc, GoRouter, Supabase, Chapa (payments).
Architecture: feature-based folders,UI -> Bloc ->UseCases ->Repository ->Api(Supabase) pattern.
Do NOT use Stripe Connect — this is Ethiopia. Payouts go via Chapa or manual bank transfer.

---

## Database — new columns and tables required

Run these migrations before writing any Flutter code:

```sql
-- Add CONFIRMED state to bookings (create table if it doesn't exist yet)
CREATE TABLE IF NOT EXISTS bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id uuid NOT NULL REFERENCES users(id),
  stylist_id uuid NOT NULL REFERENCES stylists(id),
  service_id uuid NOT NULL REFERENCES services(id),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN (
      'pending',       -- client booked, awaiting stylist acceptance
      'confirmed',     -- stylist accepted, not yet started
      'in_progress',   -- stylist marked as started
      'completed',     -- stylist marked as done
      'cancelled',     -- either party cancelled
      'missed'         -- stylist didn't respond in time
    )),
  scheduled_at timestamptz NOT NULL,
  address text NOT NULL,
  latitude numeric(10,8),
  longitude numeric(11,8),
  total_amount numeric(10,2) NOT NULL,
  platform_fee numeric(10,2) NOT NULL,
  stylist_earnings numeric(10,2) NOT NULL,
  notes text,
  cancelled_by text CHECK (cancelled_by IN ('client','stylist','system')),
  cancellation_reason text,
  accept_deadline timestamptz,  -- set to now()+15min when created
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Wallet: add security_deposit column to separate it from earnings
ALTER TABLE wallets
  ADD COLUMN IF NOT EXISTS security_deposit numeric(10,2) DEFAULT 0 NOT NULL,
  ADD COLUMN IF NOT EXISTS minimum_deposit numeric(10,2) DEFAULT 500 NOT NULL,
  ADD COLUMN IF NOT EXISTS deposit_verified boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT false;

-- Trigger: auto-activate stylist when deposit is verified
CREATE OR REPLACE FUNCTION activate_stylist_on_deposit()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deposit_verified = true AND OLD.deposit_verified = false THEN
    UPDATE stylists
    SET is_verified = true
    WHERE id = NEW.stylist_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_activate_on_deposit
  AFTER UPDATE ON wallets
  FOR EACH ROW EXECUTE FUNCTION activate_stylist_on_deposit();

-- Trigger: auto-set accept_deadline on booking insert
CREATE OR REPLACE FUNCTION set_accept_deadline()
RETURNS TRIGGER AS $$
BEGIN
  NEW.accept_deadline := now() + interval '15 minutes';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_booking_deadline
  BEFORE INSERT ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_accept_deadline();

-- Trigger: auto-miss bookings past deadline (run via cron or pg_cron)
-- Call this function from a Supabase Edge Function on a schedule
CREATE OR REPLACE FUNCTION expire_pending_bookings()
RETURNS void AS $$
BEGIN
  UPDATE bookings
  SET status = 'missed', cancelled_by = 'system', updated_at = now()
  WHERE status = 'pending'
    AND accept_deadline < now();
END;
$$ LANGUAGE plpgsql;

-- RLS
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "stylist_sees_own_bookings" ON bookings
  FOR SELECT USING (
    stylist_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );

CREATE POLICY "stylist_updates_own_bookings" ON bookings
  FOR UPDATE USING (
    stylist_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  )
  WITH CHECK (
    -- Stylists may only move status forward — they cannot set to 'cancelled' by client
    status IN ('confirmed', 'in_progress', 'completed', 'cancelled')
  );
```

---

## Folder Structure

```
lib/
  features/
    home/
      providers/
        bookings_provider.dart         ← AsyncNotifier with Supabase realtime
        booking_actions_provider.dart  ← accept/decline/start/complete actions
      repositories/
        bookings_repository.dart
      models/
        booking_model.dart
      pages/
        home_page.dart                 ← tab shell with today strip + TabBar
      widgets/
        today_summary_card.dart
        pending_booking_card.dart
        active_booking_card.dart
        booking_history_tile.dart
        accept_decline_bottom_sheet.dart
        countdown_timer_widget.dart

    wallet/
      providers/
        wallet_provider.dart
        transactions_provider.dart
        withdraw_provider.dart
      repositories/
        wallet_repository.dart
      models/
        wallet_model.dart
        transaction_model.dart
      pages/
        wallet_page.dart
      widgets/
        balance_card.dart
        deposit_banner.dart
        deposit_sheet.dart
        withdraw_sheet.dart
        transaction_list_tile.dart
        transaction_filter_bar.dart

    settings/
      providers/
        profile_provider.dart
        availability_provider.dart
        portfolio_provider.dart
        payout_account_provider.dart
      repositories/
        settings_repository.dart
      pages/
        settings_page.dart
        edit_profile_page.dart
        edit_availability_page.dart
        manage_portfolio_page.dart
        edit_payout_account_page.dart
        notification_preferences_page.dart
      widgets/
        settings_tile.dart
        account_status_banner.dart

    shell/
      pages/
        main_shell.dart                ← BottomNavigationBar wrapper
```

---

## Main Shell — `main_shell.dart`

- Uses `BottomNavigationBar` with 3 items using Tabler icons (via a font icon package):
  - Index 0: Home — icon: calendar/grid, label "Home"
  - Index 1: Wallet — icon: wallet, label "Wallet"
  - Index 2: Settings — icon: settings, label "Settings"
- Current tab index is stored in a Bloc `StateProvider<int>` called `activeTabProvider`
- On tab 0 (Home): show a badge on the bottom nav icon if there are pending bookings awaiting acceptance. Use a `StreamProvider` for the pending count.
- The shell is wrapped in a `Scaffold` with `resizeToAvoidBottomInset: false`
- Navigate between tabs using `IndexedStack` to preserve scroll position and state

---

## HOME DASHBOARD

### `home_page.dart`

Layout from top to bottom:
1. `TodaySummaryCard` — a horizontal strip at top
2. `TabBar` with 3 tabs: "Pending", "Active", "History"
3. `TabBarView` — one list per tab

#### Today summary card (`today_summary_card.dart`)

Fetch from Supabase on page load:
```dart
// Today's earnings: sum of wallet_transactions where source='booking_earning' and created_at >= today
// Today's bookings count: bookings where stylist_id=me and scheduled_at >= today
// Avg rating: stylists.avg_rating (already denormalized)
```

Display as a horizontal row of 3 metric tiles inside a card:
- Today's earnings (ETB amount)
- Bookings today (count)
- Rating (show star + number)

#### Bookings realtime subscription

In `bookings_provider.dart`, use a Bloc `AsyncNotifier`:
```dart
class BookingsNotifier extends AsyncNotifier<List<BookingModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<BookingModel>> build() async {
    final stylistId = await _getStylistId();
    _subscribeToRealtime(stylistId);
    ref.onDispose(() => _channel?.unsubscribe());
    return _fetchAll(stylistId);
  }

  void _subscribeToRealtime(String stylistId) {
    _channel = supabase
      .channel('bookings:$stylistId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'bookings',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'stylist_id',
          value: stylistId,
        ),
        callback: (payload) => ref.invalidateSelf(),
      )
      .subscribe();
  }
}
```

#### Pending bookings tab

List of `PendingBookingCard` widgets. Each card shows:
- Client name and profile photo (circular avatar)
- Service name and duration
- Scheduled date/time
- Address (truncated to 1 line)
- Total amount (ETB)
- A `CountdownTimerWidget` showing time remaining to accept (based on `accept_deadline`)
- Two large bottom buttons: **Accept** (teal) and **Decline** (outlined/gray)

On "Accept":
```dart
await supabase.from('bookings').update({
  'status': 'confirmed',
  'updated_at': DateTime.now().toIso8601String(),
}).eq('id', bookingId);
// Also: notify client via Supabase Edge Function / push notification (TODO)
```

On "Decline":
- Show a bottom sheet asking for a reason (free text, optional)
- Update `status = 'cancelled'`, `cancelled_by = 'stylist'`, `cancellation_reason = reason`

`CountdownTimerWidget`:
- Uses a `Timer.periodic(Duration(seconds: 1))` to count down from `accept_deadline - now()`
- Turns red when < 2 minutes remaining
- Shows "00:00" and greys out the Accept button when expired
- When timer hits zero, show a "This booking has expired" chip instead of buttons

#### Active booking tab

Shows at most ONE active booking (status = `confirmed` or `in_progress`). If none, show an empty state illustration.

`ActiveBookingCard` for `confirmed` status:
- Large card with all booking details
- A "Get Directions" button that opens Google Maps with the client's lat/lng using `url_launcher`: `https://maps.google.com?q={lat},{lng}`
- A prominent "I've arrived — Start service" button
  - On tap: update `status = 'in_progress'`, set `started_at = now()`

`ActiveBookingCard` for `in_progress` status:
- Shows elapsed time since `started_at` using a running timer
- A green "Mark as Completed" button
  - On tap: show a confirmation dialog "Are you sure you've finished this service?"
  - On confirm: update `status = 'completed'`, set `completed_at = now()`
  - After update: trigger the earnings credit to wallet (Supabase Postgres function or Edge Function):
    ```sql
    -- Call this after booking completed:
    INSERT INTO wallet_transactions (wallet_id, booking_id, transaction_type, amount, source)
    SELECT w.id, $booking_id, 'credit', b.stylist_earnings, 'booking_earning'
    FROM wallets w JOIN bookings b ON b.stylist_id = w.stylist_id
    WHERE b.id = $booking_id;

    UPDATE wallets SET balance = balance + (
      SELECT stylist_earnings FROM bookings WHERE id = $booking_id
    ), updated_at = now()
    WHERE stylist_id = (SELECT stylist_id FROM bookings WHERE id = $booking_id);
    ```

#### History tab

List of bookings with status in `['completed', 'cancelled', 'missed']`, ordered by date descending.

`BookingHistoryTile` for each:
- Service name, date, client name
- Status chip: green for completed, red for cancelled/missed
- Amount earned (shown only for completed)
- Tappable to expand and see full details

Add a filter row at the top: "All | Completed | Cancelled" — filter client-side from the already-fetched list.

---

## WALLET DASHBOARD

### Architecture note — two balance types

The `wallets` table has two distinct balance concepts:
- `security_deposit`: the minimum amount the stylist deposited to activate their account. This is locked and cannot be withdrawn below `minimum_deposit`.
- `balance`: total available earnings. The withdrawable amount is `balance - minimum_deposit` (i.e. `balance` minus what must be kept as deposit).

Show these separately in the UI. Never merge them into one number.

### `wallet_page.dart`

Layout from top to bottom:
1. Deposit required banner (conditional)
2. Balance card
3. Action row: Deposit button | Withdraw button
4. Transaction filter bar
5. Transaction list

#### Deposit required banner (`deposit_banner.dart`)

Show this banner when `wallets.deposit_verified = false` OR `wallets.security_deposit < wallets.minimum_deposit`.

```dart
if (!wallet.depositVerified || wallet.securityDeposit < wallet.minimumDeposit)
  DepositBanner(
    requiredAmount: wallet.minimumDeposit,
    onTap: () => showDepositSheet(context),
  )
```

Banner design:
- Full-width amber/warning colored card
- Icon + text: "You need to deposit ETB {amount} to start accepting bookings"
- A "Make deposit" CTA button
- This banner gates the entire home tab as well: if deposit not verified, show this banner on the home tab instead of the booking list, with the same CTA

#### Balance card (`balance_card.dart`)

Three-row layout inside a card:
```
Security Deposit     ETB  500.00   (locked)
Available Earnings   ETB 1,240.00
─────────────────────────────────
Total Balance        ETB 1,740.00
```

- "Security Deposit" row: show a lock icon, muted color
- "Available Earnings" row: highlight in primary color
- Divider + total at the bottom in bold
- Below the card, show: "Withdrawable: ETB {balance - minimum_deposit}" in small muted text

#### Deposit flow (`deposit_sheet.dart`)

Shown as a `DraggableScrollableSheet` bottom sheet:

1. Show the required minimum deposit amount
2. Allow stylist to enter a custom amount (must be >= minimum_deposit)
3. Show payment instructions:
   - "Pay via Chapa" button → `// TODO: Chapa SDK integration. For now, show manual instructions`
   - Manual fallback: "Transfer to our bank account: [CBE, Account: XXXXXXXX, Name: Platform Name]"
   - "I've paid — upload proof" button → opens image picker to upload payment proof
4. On proof upload:
   - Store proof image in Supabase Storage: `deposit-proofs/{stylist_id}/{timestamp}.jpg`
   - Insert into `wallet_transactions`: `{transaction_type: 'credit', source: 'topup', amount: entered_amount, metadata: {proof_url, status: 'pending_verification'}}`
   - Show: "Your deposit is under review. We'll notify you within 24 hours."
   - Admin must manually verify and set `wallets.deposit_verified = true` and update `security_deposit`

#### Withdraw flow (`withdraw_sheet.dart`)

Shown as a bottom sheet:

Validation chain (all must pass before enabling the Withdraw button):
```dart
final withdrawable = wallet.balance - wallet.minimumDeposit;
final minimumWithdrawal = 200.0; // ETB

if (wallet.securityDeposit < wallet.minimumDeposit) {
  // Show: "You cannot withdraw until your security deposit is verified"
}
if (!wallet.depositVerified) {
  // Show: "Account not yet verified"
}
if (amount > withdrawable) {
  // Show: "You can withdraw at most ETB {withdrawable}"
}
if (amount < minimumWithdrawal) {
  // Show: "Minimum withdrawal is ETB {minimumWithdrawal}"
}
```

UI fields:
- Amount input (numeric, pre-filled with withdrawable amount)
- Display payout account: bank name + masked account number (last 4 digits) from `stylist_payout_accounts`
- "Change payout account" link → navigates to Settings > Payout account
- Terms reminder: "Withdrawals are processed within 2-3 business days"
- Withdraw button (disabled until all validations pass)

On confirm:
```dart
// 1. Debit the wallet immediately (balance held, not yet paid)
await supabase.from('wallet_transactions').insert({
  'wallet_id': walletId,
  'transaction_type': 'debit',
  'amount': amount,
  'source': 'withdrawal',
  'reference': 'WITHDRAW-${DateTime.now().millisecondsSinceEpoch}',
  'metadata': {'status': 'pending', 'payout_account_id': payoutAccountId},
});

await supabase.from('wallets').update({
  'balance': wallet.balance - amount,
  'updated_at': DateTime.now().toIso8601String(),
}).eq('id', walletId);

// 2. Insert into payouts table
await supabase.from('payouts').insert({
  'wallet_id': walletId,
  'amount': amount,
  'payout_method': 'bank_transfer',
  'status': 'pending',
  'metadata': {'payout_account_id': payoutAccountId},
});
// Admin processes the actual bank transfer manually
```

#### Transaction history

Fetch from `wallet_transactions` ordered by `created_at DESC`.

`TransactionFilterBar`: horizontal chip row: "All | Earnings | Deposits | Withdrawals"

Filter mapping:
- Earnings → `source = 'booking_earning'`
- Deposits → `source = 'topup'`
- Withdrawals → `source = 'withdrawal'`

`TransactionListTile` for each:
- Left: icon based on source (up arrow for earnings/deposit, down arrow for withdrawal)
- Center: source label + date + reference
- Right: amount with color (green for credit, red for debit)
- Show "pending" badge if `metadata->>'status' = 'pending_verification'`

Use infinite scroll / pagination: load 20 at a time, load more on scroll to bottom.

---

## SETTINGS DASHBOARD

### `settings_page.dart`

A `ListView` of grouped `SettingsTile` widgets. No app bar — just a "Settings" heading as a list header.

Layout sections:

**Account status banner** (top):
- Show `account_status_banner.dart` based on `stylists.onboarding_status`:
  - `pending_review`: amber banner "Your account is under review"
  - `rejected`: red banner "Your account was not approved — Reason: {rejection_reason}" + "Resubmit" button
  - `approved`: no banner (happy path)

**Section: Profile**
- "Edit profile" tile → push to `EditProfilePage`
- "Manage portfolio" tile → push to `ManagePortfolioPage`

**Section: Schedule**
- "Edit availability" tile → push to `EditAvailabilityPage`

**Section: Payments**
- "Payout account" tile → shows current bank name + masked account → push to `EditPayoutAccountPage`

**Section: Preferences**
- "Notifications" tile → push to `NotificationPreferencesPage`

**Section: Support**
- "Help & Support" tile → opens email/WhatsApp link (use `url_launcher`)
- "Privacy Policy" tile → opens WebView or URL
- "Terms of Service" tile → opens WebView or URL

**Section: Account**
- "Sign out" tile → `supabase.auth.signOut()` then navigate to splash/login
- "Deactivate account" tile (danger color) → confirmation dialog then mark `stylists.onboarding_status = 'suspended'` and sign out

---

### `edit_profile_page.dart`

Pre-populated form with current values. Fields:
- Profile photo (circular avatar, tap to change via `image_picker`)
- Full name (maps to `users.name`)
- Business name (maps to `stylists.business_name`)
- Bio / description (maps to `stylists.description`, multiline, max 300 chars)
- Phone (maps to `users.phone`)
- Location — auto-fetch button + display address. Updates `stylists.latitude`, `stylists.longitude`
- Service radius slider (maps to `stylists.service_radius_km`)

On save:
- Upload new profile photo if changed → update `stylists.image_url`
- Update `users` row for name/phone
- Update `stylists` row for business_name, description, lat/lng, radius
- Show a `SnackBar` on success/failure

---

### `manage_portfolio_page.dart`

A `GridView.builder` with 3 columns showing portfolio photos from `stylist_portfolio`.

Each tile:
- Shows the image
- Long-press or tap: show options (View full screen, Delete)
- A special "+" tile at the end → tap to add new photos (image picker, multi-select)

On add:
- Compress each image (max 1200px, 80% quality using `flutter_image_compress`)
- Upload to `stylist-portfolios/{stylist_id}/{timestamp}.jpg`
- Insert into `stylist_portfolio`

On delete:
- Confirmation dialog
- Delete from Supabase Storage
- Delete row from `stylist_portfolio`

---

### `edit_availability_page.dart`

Reuse the `DayHourSelector` widget from the onboarding wizard. Pre-populate from `stylists_availability`.

On save:
- Delete all existing rows for this stylist: `DELETE FROM stylists_availability WHERE stylists_id = me`
- Reinsert all active days with new times

---

### `edit_payout_account_page.dart`

Pre-populated with current `stylist_payout_accounts` row (primary account).

Fields:
- Bank name (dropdown, same list as onboarding)
- Account holder name
- Account number

On save:
- Upsert the primary account row
- Show confirmation: "Your payout details have been updated. The next withdrawal will use these details."

Note: If a withdrawal is `pending` when they change details, show a warning: "You have a pending withdrawal. Changing your bank account now won't affect it."

---

### `notification_preferences_page.dart`

A list of `SwitchListTile` items stored in Supabase in a `stylist_preferences` jsonb column (add `preferences jsonb DEFAULT '{}'` to `stylists` table):

```dart
final preferences = {
  'new_booking': true,       // New booking request received
  'booking_cancelled': true, // Client cancelled a booking
  'payment_received': true,  // Earnings credited to wallet
  'deposit_verified': true,  // Security deposit confirmed
  'withdrawal_processed': true,
  'promotions': false,       // Optional: platform promotions
};
```

On toggle change: immediately upsert to Supabase (`stylists.preferences`).

---

## Error handling rules (apply everywhere)

```dart
// Wrap ALL Supabase calls:
try {
  // ... supabase call
} on PostgrestException catch (e) {
  ref.read(errorProvider.notifier).show(_mapError(e.code));
} catch (e) {
  ref.read(errorProvider.notifier).show('Something went wrong. Please try again.');
}

String _mapError(String? code) => switch (code) {
  '23505' => 'This record already exists',
  '42501' => 'You don\'t have permission to do that',
  _ => 'Something went wrong. Please try again.',
};
```

Never show raw Postgres error messages. Use a global `errorProvider` that triggers a `SnackBar`.

---

## Booking state machine — enforce on both client and database

```
PENDING ──(stylist accepts)──► CONFIRMED ──(stylist starts)──► IN_PROGRESS ──(stylist finishes)──► COMPLETED
   │                                │
   │ (timer expires)                │ (either cancels)
   ▼                                ▼
 MISSED                          CANCELLED
```

Allowed transitions from stylist side only:
- `pending → confirmed` (accept)
- `pending → cancelled` (decline)
- `confirmed → in_progress` (start)
- `confirmed → cancelled` (cancel before starting)
- `in_progress → completed` (complete)

The stylist CANNOT set status to `missed` (system only, via scheduled function).
The stylist CANNOT set status to `cancelled` with `cancelled_by = 'client'` (RLS enforces this).

---

## What NOT to implement

- Push notification delivery (leave `// TODO: trigger push via FCM/Supabase Edge Function` at each action point)
- Chapa SDK for deposit (leave `// TODO: Chapa SDK initiation` and show manual bank transfer instructions)
- Admin dashboard (not in scope for this prompt)
- In-app chat between stylist and client (leave a TODO)
- Rating / review submission from stylist side

---

## Deliverables expected

1. All SQL migration files
2. All Dart files in the folder structure above
3. `pubspec.yaml` additions for any new packages
4. Inline `// TODO` comments at every integration point (push, Chapa, etc.)

Start with: SQL migrations → BookingModel and WalletModel → providers → pages in order: Home → Wallet → Settings.
