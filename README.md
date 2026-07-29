# Load Calculator

Offline Flutter app for managing a parts catalog and calculating total load weights. Data is stored locally in SQLite — no internet connection required.

## Features

- **Parts library** — add parts manually with part number, optional description, weight (kg), and optional vendor name
- **Excel import** — bulk import or update parts from `.xlsx` files
- **Load calculator** — search by part code or description, enter quantity, and view a detailed weight breakdown with grand total
- **Offline-first** — all data stored in SQLite on device

## Excel Import Format

Your Excel file must have a header row with these columns (names are flexible):

| Part No | Description | Weight (kg) | Vendor Name |
|---------|-------------|-------------|-------------|
| ABC-001 | Sample bracket | 2.5 | Acme Corp |

- **Part No** — required, must be unique
- **Description** — optional
- **Weight (kg)** — required, numeric value greater than 0
- **Vendor Name** — optional

Importing a part number that already exists will **update** that part's weight, description, and vendor.

A sample template is bundled in the app (`assets/templates/parts_template.xlsx`) and can be shared from the Import Excel screen.

## Install on Android (GitHub Releases)

1. Go to the [Releases](../../releases) page for this repository.
2. Download the latest `app-release.apk`.
3. On your Android device, enable **Install unknown apps** for your browser or file manager (Settings → Security).
4. Open the downloaded APK and install.

### Create a release (maintainers)

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will build the release APK and attach it to the release automatically.

## Install on iOS

iOS apps cannot be sideloaded from GitHub like Android APKs. Options:

### Option A: TestFlight (recommended for teams)

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/).
2. Configure code signing in Xcode (`ios/Runner.xcodeproj`).
3. Archive and upload to App Store Connect.
4. Distribute via TestFlight to your users.

### Option B: Local build (developer machine)

```bash
flutter pub get
dart run tool/generate_template.dart
flutter run
```

Or open `ios/Runner.xcworkspace` in Xcode, select your device, and run with your provisioning profile.

## Development

### Prerequisites

- Flutter SDK (stable channel)
- Android Studio / Xcode for device builds

### Setup

```bash
flutter pub get
dart run tool/generate_template.dart
flutter run
```

### Build Android APK locally

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── database/       # SQLite setup
├── models/         # Part, CalcLineItem
├── providers/      # State management (provider)
├── repositories/   # Data access layer
├── services/       # Excel import
├── screens/        # UI screens
└── widgets/        # Reusable components
```

## License

Private project — all rights reserved unless otherwise specified.
