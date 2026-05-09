# Stylist Onboarding Wizard — Full Implementation Prompt

---

## Context & Project Overview

I am building a **Flutter + Supabase** mobile app for an on-demand beauty salon service where stylists provide services at the client's location. The app has two separate Flutter projects: one for clients (already built) and one for stylists (currently being built). The backend is **Supabase** (PostgreSQL + Auth + Storage). The in-app currency is **Ethiopian Birr (ETB)**. Stripe Connect is NOT available in Ethiopia, so payouts are handled via **Chapa** (Ethiopian payment gateway) or manual bank transfer. Stripe is still used on the client side for card payments only.

I need you to implement the **complete stylist registration and onboarding wizard** — from the first screen to the point where the stylist submits everything and waits for admin approval. Do not implement the admin side.

---

## Database Schema (existing — do not modify these tables, only add to them)

```sql
CREATE TABLE users (
  id uuid DEFAULT auth.uid() NOT NULL PRIMARY KEY,
  created_at timestamptz DEFAULT now() NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  name text NOT NULL
);

CREATE TABLE stylists (
  id uuid DEFAULT uuid_generate_v4() NOT NULL PRIMARY KEY,
  business_name text NOT NULL,
  description text,
  service_radius_km integer DEFAULT 10,
  is_verified boolean DEFAULT false,
  avg_rating numeric(3,2) DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  latitude numeric(10,8),
  longitude numeric(11,8),
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE stylists_availability (
  id uuid DEFAULT uuid_generate_v4() NOT NULL PRIMARY KEY,
  stylists_id uuid NOT NULL REFERENCES stylists(id),
  day_of_week text NOT NULL,
  start_time time NOT NULL,
  end_time time NOT NULL,
  is_available boolean DEFAULT true
);

CREATE TABLE stylists_services (
  id uuid DEFAULT uuid_generate_v4() NOT NULL PRIMARY KEY,
  stylists_id uuid NOT NULL REFERENCES stylists(id),
  service_id uuid NOT NULL REFERENCES services(id),
  price numeric(10,2) NOT NULL,
  is_available boolean DEFAULT true
);

CREATE TABLE services (
  id uuid DEFAULT uuid_generate_v4() NOT NULL PRIMARY KEY,
  name text NOT NULL,
  description text,
  category_id uuid,
  duration_minutes integer NOT NULL,
  base_price numeric(10,2) NOT NULL,
  min_price numeric(10,2),
  is_active boolean DEFAULT true,
  icon_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE wallets (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  stylist_id uuid NOT NULL REFERENCES stylists(id),
  balance numeric(10,2) DEFAULT 0 NOT NULL,
  currency text DEFAULT 'etb' NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

---

## New Tables to Create (migrations)

Before implementing any Flutter code, generate and apply the following Supabase migration file:

```sql
-- 1. Link stylists to auth users and add onboarding tracking
ALTER TABLE stylists
  ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS onboarding_status text DEFAULT 'basic_info'
    CHECK (onboarding_status IN (
      'basic_info', 'email_verified', 'kyc_submitted',
      'professional_submitted', 'wallet_done',
      'pending_review', 'approved', 'rejected'
    )),
  ADD COLUMN IF NOT EXISTS years_experience integer,
  ADD COLUMN IF NOT EXISTS rejection_reason text;

-- 2. KYC and license document storage
CREATE TABLE IF NOT EXISTS stylist_documents (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  stylist_id uuid NOT NULL REFERENCES stylists(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN (
    'national_id_front', 'national_id_back', 'selfie', 'license'
  )),
  file_url text NOT NULL,
  verified boolean DEFAULT false,
  uploaded_at timestamptz DEFAULT now()
);

-- 3. Payout / bank account details
CREATE TABLE IF NOT EXISTS stylist_payout_accounts (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  stylist_id uuid NOT NULL REFERENCES stylists(id) ON DELETE CASCADE,
  account_holder_name text NOT NULL,
  bank_name text NOT NULL,
  account_number text NOT NULL,
  is_primary boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- 4. Portfolio photos
CREATE TABLE IF NOT EXISTS stylist_portfolio (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  stylist_id uuid NOT NULL REFERENCES stylists(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  caption text,
  created_at timestamptz DEFAULT now()
);

-- 5. RLS policies
ALTER TABLE stylists ENABLE ROW LEVEL SECURITY;
ALTER TABLE stylist_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE stylist_payout_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE stylist_portfolio ENABLE ROW LEVEL SECURITY;
ALTER TABLE stylists_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE stylists_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

-- Stylists can only read/write their own row
CREATE POLICY "stylist_self_access" ON stylists
  FOR ALL USING (user_id = auth.uid());

-- Stylist cannot update their own onboarding_status or is_verified (admin only)
CREATE POLICY "stylist_no_status_escalation" ON stylists
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (
    onboarding_status NOT IN ('approved') AND
    is_verified = false
  );

-- Documents, payout accounts, portfolio: stylist owns their own rows
CREATE POLICY "stylist_documents_self" ON stylist_documents
  FOR ALL USING (
    stylist_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );

CREATE POLICY "stylist_payout_self" ON stylist_payout_accounts
  FOR ALL USING (
    stylist_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );

CREATE POLICY "stylist_portfolio_self" ON stylist_portfolio
  FOR ALL USING (
    stylist_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );

CREATE POLICY "stylist_availability_self" ON stylists_availability
  FOR ALL USING (
    stylists_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );

CREATE POLICY "stylist_services_self" ON stylists_services
  FOR ALL USING (
    stylists_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );

CREATE POLICY "wallet_self" ON wallets
  FOR SELECT USING (
    stylist_id IN (SELECT id FROM stylists WHERE user_id = auth.uid())
  );
```

---

## Supabase Storage Buckets

Create the following private storage buckets (not public):

- `stylist-kyc-docs` — for national ID front, back, and selfie images
- `stylist-licenses` — for professional license/certification uploads
- `stylist-portfolios` — for portfolio photos
- `stylist-profile-photos` — for profile pictures

Storage policies: authenticated user can upload only to paths prefixed with their `auth.uid()`. Example path format: `{bucket}/{auth.uid()}/{filename}`. No public read access on kyc-docs or licenses buckets. Portfolio and profile photos can have public read.

---

## Flutter Architecture

Use the following architecture:

- **State management**: Riverpod (with `flutter_riverpod` and `riverpod_annotation`)
- **Navigation**: GoRouter
- **Supabase client**: `supabase_flutter`
- **File upload**: `image_picker` for photo selection
- **Location**: `geolocator` + `geocoding` packages (same as client app)
- **KYC / Liveness**: `smile_id` Flutter SDK (`smile_id_smart_selfie` package) — this works in Ethiopia and supports Ethiopian national IDs
- **Form validation**: `flutter_form_builder` + `form_builder_validators`

### Folder structure to follow:
```
lib/
  features/
    auth/
      onboarding/
        providers/
          onboarding_provider.dart        ← Riverpod notifier holding wizard state
        repositories/
          onboarding_repository.dart      ← all Supabase calls for onboarding
        models/
          onboarding_state.dart           ← immutable state model for full wizard
        pages/
          onboarding_wrapper.dart         ← wizard shell with progress bar
          page1_basic_info.dart
          page1b_email_otp.dart
          page2_kyc.dart
          page3_professional.dart
          page4_wallet.dart
          onboarding_submitted.dart       ← success / pending review screen
        widgets/
          wizard_progress_bar.dart
          document_upload_tile.dart
          day_hour_selector.dart
          service_chip_grid.dart
          radius_slider.dart
```

---

## Onboarding State Model

```dart
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    // Page 1
    String? fullName,
    String? email,
    String? phone,
    String? businessName,
    File? profilePhoto,
    double? latitude,
    double? longitude,
    String? locationAddress,

    // Page 2 — KYC
    File? nationalIdFront,
    File? nationalIdBack,
    String? selfieImagePath,       // returned by Smile ID SDK
    bool selfieVerified = false,

    // Page 3 — Professional
    File? licenseFile,
    int? yearsExperience,
    List<String>? selectedServiceIds,
    Map<String, double>? servicePrices, // serviceId → custom price
    List<AvailabilitySlot>? availability,
    int serviceRadiusKm = 10,
    List<File>? portfolioPhotos,

    // Page 4 — Wallet
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    bool termsAccepted = false,

    // Wizard progress
    int currentStep = 0,
    bool isLoading = false,
    String? errorMessage,
    String? stylistId,             // set after first Supabase insert
  }) = _OnboardingState;
}
```

---

## Wizard Shell — `onboarding_wrapper.dart`

- Displays a horizontal step progress bar at the top showing 4 steps: "Basic Info", "Identity", "Professional", "Wallet"
- Current step is highlighted, completed steps show a checkmark
- Each page is shown inside the same scaffold; navigation between pages is done by incrementing `currentStep` in the provider — do NOT use GoRouter pushes between wizard pages
- The "Back" button decrements `currentStep` (does not pop the route)
- The shell also shows a circular progress indicator overlay when `isLoading = true`
- On cold start, check Supabase for an existing `stylists` row with `user_id = auth.uid()` and resume from the saved `onboarding_status`

---

## Page 1 — Basic Info (`page1_basic_info.dart`)

**Fields:**
1. Profile photo — circular avatar with a camera icon tap to open `image_picker` (gallery or camera choice via bottom sheet)
2. Full name — text field, required, min 2 chars
3. Email — text field, required, email format validation
4. Phone number — text field, required, Ethiopian format (+251 prefix selector)
5. Business / salon name — text field, required ("What do you call your practice?")
6. Location — not a text field. Show a card that says "Fetching your location…" and auto-fetches using `geolocator`. Display the resolved address string from `geocoding`. Show a retry button if it fails. Store lat/lng.

**On "Continue":**
1. Validate all fields
2. Call `supabase.auth.signUp(email: email, password: generatedTempPassword)` — store the temp password securely in local state (it will never be used again; magic link / OTP is the login method)
3. OR use `supabase.auth.signInWithOtp(email: email)` if you prefer passwordless from the start
4. Insert a row into `users` table: `{id: auth.uid(), email, phone, name: fullName}`
5. Insert a row into `stylists` table: `{user_id: auth.uid(), business_name, latitude, longitude, onboarding_status: 'basic_info'}`
6. Upload profile photo to `stylist-profile-photos/{auth.uid()}/profile.jpg`, save returned URL to `stylists.image_url`
7. Save `stylistId` into provider state
8. Advance to OTP screen

---

## Page 1b — Email OTP (`page1b_email_otp.dart`)

- Full screen with an illustration, "Check your email" heading, and the email address shown
- 6-digit OTP input using a `PinCodeTextField` (use `pin_code_fields` package)
- "Resend code" button with a 60-second cooldown timer
- On verify: call `supabase.auth.verifyOTP(email: email, token: otp, type: OtpType.email)`
- On success: update `stylists.onboarding_status = 'email_verified'`, advance to Page 2
- On failure: show inline error, do not advance

---

## Page 2 — KYC / Identity (`page2_kyc.dart`)

**This page has 3 sub-steps rendered sequentially in the same screen (not separate routes):**

### Sub-step A — National ID front
- A large dashed-border upload box with an ID card illustration inside
- Tap → `image_picker` opens camera (preferred) or gallery
- After selection, show a thumbnail preview of the captured image with a "Retake" option
- Label: "Front of your national ID / Kebele ID"

### Sub-step B — National ID back
- Same UI as sub-step A
- Label: "Back of your national ID / Kebele ID"
- Only shown after sub-step A is completed (animate in with a slide transition)

### Sub-step C — Selfie liveness check
- Show a card explaining what will happen: "We'll take a short selfie video to confirm you're a real person"
- A prominent "Start liveness check" button
- On tap: launch the **Smile Identity SmartSelfie** SDK:
  ```dart
  SmileID.authenticate(
    request: AuthenticationRequest(
      userId: stylistId,
      jobType: JobType.smartSelfieEnrollment,
    ),
  );
  ```
- On SDK success callback: set `selfieVerified = true`, store the returned `selfieImagePath`
- If Smile ID is not yet integrated or in dev mode: fall back to a simple front-camera selfie capture using the `camera` package and skip liveness — add a `// TODO: replace with Smile ID in production` comment

**On "Continue" (after all 3 sub-steps):**
1. Upload `nationalIdFront` to `stylist-kyc-docs/{auth.uid()}/id_front.jpg`
2. Upload `nationalIdBack` to `stylist-kyc-docs/{auth.uid()}/id_back.jpg`
3. Upload selfie to `stylist-kyc-docs/{auth.uid()}/selfie.jpg`
4. Insert 3 rows into `stylist_documents`: one per document type with the storage URL
5. Update `stylists.onboarding_status = 'kyc_submitted'`
6. Advance to Page 3

---

## Page 3 — Professional Details (`page3_professional.dart`)

This page is long — use a `SingleChildScrollView`. Group the sections with visible section headers (a small colored divider + label).

### Section 1 — License & Experience
- License / certification upload — same dashed-box upload UI as KYC. Accepts image or PDF (use `file_picker` package for PDF support). Label: "Cosmetology license, barbering certificate, or any official certification"
- Years of experience — a horizontal number stepper (minus / number / plus), range 0–40
- Portfolio photos — a horizontal scrollable row of photo tiles + an "Add photo" tile at the end. Minimum 3 photos recommended (show a hint, not a hard block). Each tile shows the image with a small × to remove. Use `image_picker` for selection.

### Section 2 — Service specialties
- Fetch all active services from the `services` table on page load (use a FutureProvider)
- Display them as a wrap of selectable chip cards. Each chip shows the service icon (from `icon_url`) and name.
- On chip tap: if not selected, show a bottom sheet asking for the stylist's custom price for that service (pre-filled with `services.base_price`). On confirm, add to `selectedServiceIds` and `servicePrices`.
- If already selected, tapping removes it
- Require at least 1 service selected to continue

### Section 3 — Availability
- A weekly grid: 7 rows (Mon–Sun), each row has a toggle switch + time range selector (start time, end time)
- When the toggle is ON, show two `TimePickerDialog`-based time pickers side by side
- Default state: Mon–Fri on, 9:00 AM – 6:00 PM; Sat–Sun off
- Use a reusable `DayHourSelector` widget

### Section 4 — Service area
- A labeled slider: "How far will you travel to clients?"
- Range: 1 km to 50 km, divisions at every 1 km, current value shown in a bold label above the slider
- Maps to `stylists.service_radius_km`

**On "Continue":**
1. Validate: license uploaded, at least 1 service selected, at least 1 available day
2. Upload license file to `stylist-licenses/{auth.uid()}/license.{ext}`
3. Insert row into `stylist_documents` for the license
4. Upload portfolio photos to `stylist-portfolios/{auth.uid()}/{timestamp}.jpg` for each
5. Insert rows into `stylist_portfolio`
6. Upsert rows into `stylists_services` for each selected service + price
7. Upsert rows into `stylists_availability` for each day that is toggled on
8. Update `stylists`: set `years_experience`, `service_radius_km`, `onboarding_status = 'professional_submitted'`
9. Advance to Page 4

---

## Page 4 — Wallet & Payout Setup (`page4_wallet.dart`)

### Section 1 — Bank account (required)
- Dropdown: Bank name — hardcode a list of major Ethiopian banks:
  `['Commercial Bank of Ethiopia', 'Awash Bank', 'Abyssinia Bank', 'Dashen Bank', 'Bunna Bank', 'Oromia Bank', 'Wegagen Bank', 'United Bank', 'Nib Bank', 'Cooperative Bank of Oromia']`
- Text field: Account holder name (pre-filled with stylist's full name)
- Text field: Account number (numeric keyboard, required)
- Note: do NOT store CVV, PIN, or any card secrets — only account-level info

### Section 2 — Debit card (optional)
- A card-style toggle tile: "Add a debit card for faster payouts (optional)"
- If toggled on, show:
  - Card number field (masked, 16 digits)
  - Expiry month/year
  - Cardholder name
- Mark these as `optional` clearly in the UI. In this version, store only the last 4 digits and card type (parsed from first digit) in metadata — do not store full card number in your DB. In production, tokenize via Chapa.

### Section 3 — Terms & platform fee
- A scrollable text box showing a short summary of:
  - Platform service fee (e.g. 15% per booking)
  - Payout schedule (e.g. weekly every Monday)
  - Cancellation policy
- A required checkbox: "I agree to the terms of service and platform fee policy"
- A "Read full terms" link that opens a bottom sheet or WebView with the full document

**On "Submit":**
1. Validate: bank account fields filled, terms accepted
2. Insert row into `stylist_payout_accounts`
3. Create a `wallets` row: `{stylist_id, balance: 0, currency: 'etb'}`
4. Update `stylists.onboarding_status = 'pending_review'`
5. Trigger a Supabase Edge Function (or use a Postgres trigger) that sends a notification to the admin (via email or push) that a new stylist is awaiting review
6. Navigate to the success screen (replace the wizard route entirely — no back navigation)

---

## Onboarding Submitted Screen (`onboarding_submitted.dart`)

- Full screen, no back button, no app bar
- Show a success illustration (Lottie animation preferred)
- Heading: "You're all set!"
- Body: "We've received your application. Our team will review your documents within 1–3 business days. You'll receive an email and app notification once approved."
- A "Got it" button that signs the stylist out and returns to the login/splash screen
- On next login: check `stylists.onboarding_status`. If still `pending_review`, show this same waiting screen. If `rejected`, show a rejection screen with `stylists.rejection_reason` and a "Resubmit documents" button that re-opens the wizard at Page 2.

---

## Resume Logic (critical — implement this)

In the `onboarding_wrapper.dart` `initState` (or in a Riverpod `AsyncNotifier`):

```dart
final stylist = await supabase
  .from('stylists')
  .select()
  .eq('user_id', supabase.auth.currentUser!.id)
  .maybeSingle();

if (stylist == null) {
  // Fresh registration — start at step 0
} else {
  switch (stylist['onboarding_status']) {
    case 'basic_info':    goToStep(0); break;
    case 'email_verified': goToStep(1); break; // OTP page
    case 'kyc_submitted':  goToStep(2); break;
    case 'professional_submitted': goToStep(3); break;
    case 'wallet_done':
    case 'pending_review': showSubmittedScreen(); break;
    case 'rejected':       showRejectedScreen(); break;
    case 'approved':       goToMainApp(); break;
  }
}
```

---

## Error Handling & UX Rules

- Every Supabase call must be wrapped in try/catch. Show a `SnackBar` with the error message. Never show raw Supabase/Postgres errors to the user — map them to friendly messages.
- File uploads can fail silently — always check the returned URL is non-null before inserting into the documents table.
- If an upload partially fails (e.g. 2 of 3 portfolio photos), do not block the user — save what succeeded, show a warning, and allow retry later from the profile edit screen.
- All "Continue" buttons should be disabled (greyed out) until minimum validation passes, not just on tap.
- Image compression: before uploading any photo, compress it using the `flutter_image_compress` package to max 800×800px and 80% JPEG quality. This keeps storage costs low and uploads fast on slow Ethiopian mobile connections.
- Show upload progress using a `LinearProgressIndicator` when uploading multiple files (portfolio).

---

## What NOT to implement

- Do not implement the admin review dashboard
- Do not implement post-approval stylist home screen or booking flow
- Do not implement push notifications (leave a `// TODO: trigger push notification` comment at the right spots)
- Do not implement Chapa payment SDK integration (leave a `// TODO: Chapa integration` comment in the payout section)
- Do not implement Smile ID in full — use the stub/fallback described in Page 2 with a clear TODO comment

---

## Deliverables Expected

1. All migration SQL files ready to run in Supabase
2. All Dart files listed in the folder structure above, fully implemented
3. A `pubspec.yaml` snippet with all required package additions
4. Brief inline comments on any non-obvious logic (no need to comment every line)

Start with the migration SQL, then the state model and provider, then the pages in order.
