ExpenseTracker 

> Lightweight expense tracker built with Flutter — supports per-account persistence, and platform preflight checks for reliable Android/iOS builds.

---

Quick summary

- **Framework:** Flutter (stable)
- **Purpose:** Track expenses per user account, and view spending progress
- **Platforms:** Android, iOS, macOS, Web (desktop support available)

---

Requirements

- Flutter 3.38 (or compatible stable release)
- Xcode (for iOS/macOS builds)
- Android SDK (for Android builds and emulators)
- CocoaPods (for iOS) and up-to-date platform tooling

Run `flutter doctor -v` to verify your environment.

---

Project structure 

- `lib/` — App source
- `lib/pages/` — Screens (Login, Home, Progress, etc.)
- `lib/stores/` — ChangeNotifier stores (`auth_store`, `expense_store`)
- `lib/widgets/` — Reusable widgets (e.g., `ExpenseCard`, `TextScaleLimiter`)
- `scripts/check_platform_deps.sh` — Preflight check for problematic transitive packages (e.g., `win32`)
- `test/` — Unit & widget tests
- `integration_test/` — Integration tests

-Setup & first run

1. Clone the repo and enter the project:

	 ```bash
	 git clone <repo-url>
	 cd expense_tracker
	 ```

2. Fetch dependencies:

	 ```bash
	 flutter pub get
	 ```

3. Run the preflight script before building for iOS/macOS or Android (catches Windows-only packages in dependency graph which can break packaging):

	 ```bash
	 ./scripts/check_platform_deps.sh
	 ```

4. Run static analysis:

	 ```bash
	 flutter analyze
	 ```

5. Run tests:

	 - Unit & widget tests:
		 ```bash
		 flutter test
		 ```
	 - Integration tests (requires device/emulator):
		 ```bash
		 flutter test integration_test
		 ```

---

## ▶️ Running the app

- Run on iOS simulator (macOS):

	```bash
	flutter run -d <device-id-or-name>
	```

- Build Android debug APK:

	```bash
	flutter build apk --debug
	```

- Build iOS (requires Xcode & code signing):

	```bash
	flutter build ios
	```

If you run into packaging build errors referencing packages like `win32`, run the preflight script and either upgrade the offending dependency or add a temporary `dependency_overrides` entry until upstream fixes are available. See `docs/BUILD.md` for extra guidance.

---

Notable features & UX notes

- Per-account persistence: each account's expenses are stored separately in `SharedPreferences` (keys prefixed with `expenses_v1_`). Signing out clears in-memory data; signing in reloads the appropriate stored expenses. Tests validate the sign-up/logout/login cycle. ✅
- Saved credentials: optional 'Remember me' and saved password support for convenience (stored in `SharedPreferences` for demo purposes). Consider encryption or secure storage for production. 🔐
- Accessibility guard: `TextScaleLimiter` clamps extreme OS text scaling for critical headings and large numbers to prevent layout breakage (applied to Home; can be extended to other pages). ♿

---

Tests included

- Unit tests for store persistence (`test/auth_expense_persistence_test.dart`).
- Widget tests for login/signup and saved-account flows (`test/login_signup_widget_test.dart`).

Run them with `flutter test`.

---

Troubleshooting & Known Issues

- If an iOS build fails during packaging with errors that mention Windows-only types (e.g., `UnmodifiableUint8ListView`) it usually means a Windows-only package (such as `win32`) is in the dependency graph transitively. Run the preflight script and follow the suggestions in `docs/BUILD.md`. ⚠️
- There are some `info`-level deprecation hints (e.g., `.withOpacity()` recommendations). These are not critical but should be addressed over time for code health. 🔄

---

 Recommended next steps for CI

- Add a job to run: `./scripts/check_platform_deps.sh`, `flutter analyze`, and `flutter test` on pull requests to catch regressions and platform-dependency issues early. 🔁

---

## Contributing

Contributions are welcome. Please open issues or PRs, and ensure new functionality includes tests and passes `flutter analyze` and `flutter test`.

---

## License

This project is provided for demonstration purposes. Add a license if you plan to share it publicly.
# expense_tracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
