# Mr. Coolie

Mr. Coolie is a Flutter application for workers, employers, and customers. It uses Firebase Authentication and Cloud Firestore for account profiles, jobs, applications, and worker search.

## Run locally

1. Install Flutter and Android Studio (or Chrome for a Web run).
2. From the project directory, run `flutter pub get`.
3. Confirm `lib/firebase_options.dart` and `android/app/google-services.json` belong to your Firebase project. Do not commit service-account credentials or unrestricted API keys.
4. In Firebase Console, enable the Authentication providers you need and create the Cloud Firestore database.
5. Review `firestore.rules`, then deploy with `firebase deploy --only firestore:rules`.
6. Connect a device or start an emulator, then run `flutter run` (or `flutter run -d chrome`).

## Platform setup

- Phone authentication: enable Firebase Phone sign-in, configure the Android SHA-1 fingerprint and iOS APNs setup, and use Firebase test numbers during development.
- Voice search: Android microphone permission and iOS/macOS speech and microphone usage descriptions are configured. The operating system still asks the user at runtime.
- Live location: access is requested only when a worker switches sharing on for an accepted job. Sharing is limited to that job's employer and recent coordinates. Android/iOS/macOS usage descriptions are configured.
- Worker nearby jobs use an interactive OpenStreetMap view and do not need a Google Maps key. It requires internet access, shows OpenStreetMap attribution, and uses the community tile service on a best-effort basis; for production traffic, select a tile provider with a suitable service agreement. The employer job-site map picker still uses Google Maps. To enable it, create restricted Android, iOS, and Web keys, enable billing, and restrict each key to the required Maps SDK/API and app/site. Add `maps.api.key=...` to ignored `android/local.properties`, add `MAPS_API_KEY=...` to ignored `ios/Flutter/Maps.local.xcconfig`, add the restricted Web Maps JavaScript API script to `web/index.html` locally, then run with `--dart-define=MAPS_ENABLED=true`. Do not commit or message keys.
- Direct UPI QR: after an employer marks an assigned job complete, the worker saves a UPI ID for that job under Finance → UPI payment setup. The employer scans/shares the amount-specific QR and reports the transfer; the worker confirms receipt after checking their bank/UPI app. The transfer goes directly to the worker's bank. These app records are participant-confirmed, not bank-verified, and are not a stored-value wallet. Use a payment provider with server-side verification/webhooks for automatic confirmation, refunds, or platform payouts.

## Project completion checklist

- [x] Firebase phone OTP entry flow for native platforms and Web.
- [x] Worker, employer, and customer profiles with role-specific navigation.
- [x] Job posting, applications, employer review, and worker search using Firestore.
- [x] Worker availability toggle and six-language selection state.
- [x] Voice job search and text-to-speech controls.
- [x] Consent-based worker location sharing on accepted jobs, with employer-only access and stale-location expiry rules.
- [x] Direct UPI QR for completed employer-posted jobs, per-job worker UPI setup, payer report, worker receipt confirmation, and a separately labeled reported total.
- [ ] Configure and verify Firebase Phone Auth, Firestore rules, SMS delivery, and production app signing.
- [ ] Configure Google Maps API keys, verify map tiles on Android/iOS/Web, and test nearby filtering on real devices.
- [ ] Configure a payment provider and server-side transaction/webhook verification for bank-verified payment history, refunds, or platform payouts. The current UPI QR transfers directly to the worker and is confirmed by the participants in-app.
- [ ] Add customer service booking/completion/payment flow; customer-to-worker contact requests currently do not create a priced job.
- [ ] Add verified job completion and rating records to a production Firestore backend; the current job/rating rules are drafted but not emulator-tested.
- [ ] Complete translations for every screen and verify each language with native speakers.
- [ ] Run Firestore emulator security tests and build/run on Android, iOS, Web, and desktop targets.

## Verification

Run `flutter analyze` and `flutter test` after changes. The current codebase has no Dart test files yet; add emulator-backed rules tests before production deployment. Real SMS, Maps billing, iOS builds, and device location behavior require the corresponding Firebase/Google credentials and platform setup.

### Local verification on 2026-10-19

- `flutter analyze --no-pub`: no errors or warnings; 84 info-level curly-braces lint notices remain.
- `flutter build web --no-pub`: passed after adding QR payment UI. Flutter reported WebAssembly dry-run warnings from `flutter_tts`; the normal JavaScript web build completed.
- `flutter build apk --debug --no-pub`: passed; output is `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter test --no-pub`: not run because `test/` contains no `*_test.dart` files.
- `flutter build windows --debug --no-pub`: blocked because Visual Studio C++ build tools are not installed.
- Firestore rules compiled and deployed to project `mrcoolie`; emulator behavior and authenticated end-to-end payment flows have not been tested.
- Flutter web app is running locally at `http://localhost:53915` (HTTP 200). Real UPI transfer requires a worker to enter their own valid VPA and both job participants to verify the experience with their accounts.
