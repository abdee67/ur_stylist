# ur_stylist — Agent Guide

## What this is

Flutter + Supabase on-demand beauty services app for Ethiopia (ETB). Two user flows coexist in one codebase: **customer** (browse/book/pay) and **stylist** (accept bookings, wallet, settings).

## Architecture

```
UI (Widget/Page) → Bloc → UseCase → Repository → DataSource (Supabase)
```

- **Stack**: Flutter (Dart ≥3.8.1), flutter_bloc, go_router, get_it, supabase_flutter, flutter_stripe
- **Feature folders**: `lib/features/{feature}/{data,domain,presentation}/`
- **DI wired in**: `lib/injection_container.dart` (single file, all get_it registrations)
- **Env**: `assets/.env` (gitignored) — keys: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `STRIPE_PUBLISHABLE_KEY`

## Two app shells exist — be precise

| Shell | Tabs | Used by |
|-------|------|---------|
| `lib/features/shell/…/main_shell.dart` | Home, Wallet, Settings (3-tab) | **Stylist** dashboard |
| `lib/shared/custom_bottom_nav_bar.dart` + `dashboard_wrapper.dart` | Home, Services, Booking, Stylist, Setting (5-tab) | (Old/other) |

The **stylist** shell is active via `MainShell` at routes `/home`, `/settings`. The customer 5-tab shell is legacy/partially migrated.

## Routes

Defined in `lib/routes/app_router.dart` using go_router. Route path constants in `lib/core/constants/app_routes.dart`. Onboarding check at startup via `SharedPreferences` key `hasSeenOnboarding`.

## Supabase

- **Local dev**: `supabase start` (ports: API 55321, DB 55322, Studio 55323, Inbucket 55324)
- **Migrations**: `supabase/migrations/` — 12 files, ordered by date. Run `supabase db push` to apply.
- **Realtime**: enabled; used for booking subscriptions (stylist side)
- **Edge Functions**: deploy with `supabase functions deploy`

## Schema highlights

Key tables (full schema in `schema.sql`): `customers`, `stylists`, `services`, `service_categories`, `stylists_services`, `stylists_availability`, `bookings`, `booking_services`, `payments`, `wallets`, `wallet_transactions`, `payouts`, `reviews`, `notifications`, `customer_addresses`.

Booking state machine: `pending → confirmed → in_progress → completed` (stylist side); system can set `missed`.

## Commands

```sh
flutter run              # launch app
flutter analyze          # lint (flutter_lints)
flutter test             # run tests
```

## Key conventions

- **Error handling**: Wrap Supabase calls; catch `PostgrestException`, show via global error provider (snackbar). Use `Failures` class from `lib/core/errors/`.
- **Theme**: Pink primary, `Montserrat` font (hardcoded in theme, NOT via google_fonts package). Custom font `BitcountPropSingle` for logo.
- **Payments**: Stripe (card) + manual bank transfer (`bank_transfer`). Chapa SDK is TODO.
- **All Supabase calls** go through `ApiService` base class in `lib/api/` (wraps `client.functions.invoke`).

## Gotchas

- Empty placeholder files exist: `route_names.dart`, `route_transitions.dart`, `router_config.dart`, `app_theme.dart`, `dark_theme.dart`, `theme_provider.dart`. Do not assume they have content.
- `tests/widget_test.dart` is a single placeholder test — no real test suite exists.
- `assets/.env` is gitignored but MUST exist with real keys for the app to run.
- `stylist_dashboard_prompt.md` is a design spec, NOT a source of truth for current implementation.
- `.agents/skills/`, `.continue/skills/`, `.windsurf/skills/` contain skill files for various AI coding tools.
