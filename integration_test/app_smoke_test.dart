// Smoke test that launches the REAL app (lib/main.dart), verifies the first
// screen renders, drives one interaction, and captures screenshots.
//
// Run via the driver so screenshots are written to disk:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_smoke_test.dart \
//     -d <android-device-id>
//
// GOTCHA: the onboarding screen uses AnimatedTextKit(repeatForever: true) and
// flutter_animate, so the widget tree NEVER reaches a steady state. Using
// tester.pumpAndSettle() here would hang until timeout. We pump fixed
// durations instead.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ur_stylist/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launch → onboarding → advance one page', (tester) async {
    // Boots dotenv + Supabase.initialize + Stripe + get_it DI, then runApp.
    app.main();

    // Let the async onboarding check + first frame(s) build. No pumpAndSettle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));

    // On Android the Flutter surface must be converted before takeScreenshot
    // returns real pixels instead of a blank/black image.
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }
    await binding.takeScreenshot('01-onboarding');

    // The "Next" and "Skip" controls are stable text (the animated title is
    // typed char-by-char, so don't assert on the title text).
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Drive one real interaction: advance to the second onboarding page.
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(seconds: 2));
    await binding.takeScreenshot('02-second-page');
  });
}
