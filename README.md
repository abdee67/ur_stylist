# UR Stylist

Stylist-facing Flutter app for the UR Beauty platform.

This app lets beauty professionals onboard as stylists, submit KYC and portfolio
details, manage availability, review booking requests, complete appointments,
track wallet activity, and manage payout information.

## Related Repositories

This app is part of the UR Beauty workspace:

```text
C:\flutterApps\ur_beauty\
  ur_backend\   # Supabase backend repo
  urs_beauty\   # Customer Flutter app
  ur_stylist\   # Stylist Flutter app
```

Backend changes should be made in `ur_backend`, not inside this app repo. This
keeps Supabase migrations, Edge Functions, RLS policies, storage policies, and
payment or payout logic in one shared source of truth for both apps.

## Main Features

- Stylist sign up, sign in, password reset, and OTP verification
- Multi-step stylist onboarding flow
- Basic business profile setup
- KYC document and selfie upload
- Professional details, service selection, pricing, and availability setup
- Wallet and payout account setup
- Stylist dashboard with pending, active, and historical bookings
- Booking accept, decline, start, and complete actions
- Wallet balance, security deposit, transaction history, and payout requests
- Profile, availability, portfolio, payout, and notification settings
- Notifications and shared booking status widgets

## Tech Stack

- Flutter and Dart
- Supabase Auth, Database, Storage, RPC, and Edge Functions
- Stripe initialization through `flutter_stripe`
- `flutter_bloc` for state management
- `get_it` for dependency injection
- `go_router` for navigation
- Image and file upload through `image_picker`, `file_picker`, and compression
- Location packages for address and service-area flows

## Project Structure

```text
lib/
  api/                 # API helpers and payment-related service stubs
  config/              # Supabase and routing config
  core/                # Shared constants, errors, theme, utilities, widgets
  features/            # Stylist app features organized by domain
  routes/              # App router and route names
  shared/              # Shared models and reusable widgets
  injection_container.dart
  main.dart
```

Feature modules generally follow a layered structure:

```text
features/<feature>/
  data/
  domain/
  presentation/
```

Important feature areas:

- `features/auth/` handles shared auth screens and stylist onboarding.
- `features/home/` handles dashboard bookings and booking actions.
- `features/wallet/` handles balances, deposits, transactions, and payouts.
- `features/settings/` handles profile, availability, portfolio, and payout
  account editing.
- `features/shell/` handles the main signed-in app shell.

## Environment Setup

The app loads environment values from:

```text
assets/.env
```

Required keys:

```env
SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=
STRIPE_PUBLISHABLE_KEY=
```

Optional Stripe key:

```env
STRIPE_MERCHANT_IDENTIFIER=
```

`assets/.env` is already ignored by Git. Do not commit real Supabase, Stripe,
payout, or payment-related secrets.

## Backend Dependency

This app depends on the shared Supabase backend in:

```text
C:\flutterApps\ur_beauty\ur_backend
```

Expected backend resources include:

- Supabase auth configuration
- Stylist onboarding tables and policies
- `users`, `stylists`, `services`, `bookings`, and review-related tables
- `stylist_documents`, `stylist_portfolio`, `stylists_services`, and
  `stylists_availability`
- `wallets`, `wallet_transactions`, `stylist_payout_accounts`, and `payouts`
- Storage buckets:
  - `stylist-kyc-docs`
  - `stylist-licenses`
  - `stylist-portfolios`
  - `stylist-profile-photos`
  - `deposit-proofs`
- RPC/function support for booking settlement, including
  `complete_stylist_booking`

When an app feature requires a database, storage policy, RPC, or Edge Function
change, update and deploy the backend from `ur_backend` first.

## Local Development

Install dependencies:

```powershell
flutter pub get
```

Run the app:

```powershell
flutter run
```

Run static analysis:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

## Platform Notes

The app includes Android, iOS, web, Windows, macOS, and Linux Flutter folders.
Mobile platforms are the primary target for onboarding, document uploads,
dashboard work, wallet actions, and payment-related flows.

Stripe uses the URL scheme:

```text
urstylist
```

Keep Android and iOS payment configuration aligned with the Stripe settings in
`lib/main.dart`.

## Development Rules

- Keep Flutter UI and stylist app behavior in this repo.
- Keep Supabase schema, migrations, RLS, storage policies, RPCs, and Edge
  Functions in `ur_backend`.
- Do not recreate a `supabase/` folder in this app unless there is a deliberate
  reason to change the architecture.
- Do not commit `.env` files, keys, local build outputs, uploaded test files, or
  generated caches.
- Update this README when setup steps, required environment keys, backend
  dependencies, or onboarding requirements change.
