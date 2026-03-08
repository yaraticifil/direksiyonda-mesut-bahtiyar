Android build (Play Store) — quick steps

1) Generate a release keystore (run from project root):

```bash
# Run in a shell where keytool is available (part of JDK)
keytool -genkey -v -keystore android/app/my-release-key.jks -alias your_key_alias -keyalg RSA -keysize 2048 -validity 10000
```

Follow prompts and note the passwords and alias.

2) Create `android/key.properties` (DO NOT commit):

Copy `android/key.properties.example` to `android/key.properties` and update passwords/alias and storeFile if you used a different path.

3) Add `android/key.properties` to `.gitignore` if not present.

4) Build an Android App Bundle (recommended for Play Store):

```bash
flutter pub get
flutter build appbundle --release
```

This produces `build/app/outputs/bundle/release/app-release.aab`.

Or build a universal APK (not recommended for Play Store):

```bash
flutter build apk --release
```

This produces `build/app/outputs/flutter-apk/app-release.apk`.

5) Upload the `.aab` to Google Play Console.

Notes / Troubleshooting:
- Make sure `flutter` is installed and available in PATH. On Windows you may need to set `C:\flutter\bin` (or your install path).
- If Flutter isn't available on this machine, run these commands on your development machine (or CI) with Flutter set up.

iOS (App Store) — important:
- You must build iOS artifacts on macOS with Xcode installed.
- Typical steps:
  1. On macOS, open `ios/Runner.xcworkspace` in Xcode, set signing (Apple Developer account, team) and create an Archive.
  2. Export an IPA from the Organizer or use `flutter build ipa --release` on macOS (requires Xcode command-line tools and proper signing settings).
  3. Upload using Xcode Organizer or the Transporter app to App Store Connect.

If you want, I can:
- Try to run `flutter build` here (checks Flutter availability). [Note: Windows cannot produce signed iOS builds].
- Help generate the keystore command and patch files (done), or validate `key.properties` after you create it.
