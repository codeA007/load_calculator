# Furnace Load Calculator

Offline Flutter app for managing a parts catalog, calculating total melt weight, and determining **furnace heats required**. Data is stored locally in SQLite — no internet connection required.

## Features

- **Parts library** — add parts manually with part number, optional description, weight (kg), and optional vendor name
- **Excel import** — bulk import or update parts from `.xlsx` files
- **Furnace calculator** — search by part code or description, enter quantity, and view weight breakdown with live furnace heat calculation
- **Furnace heats** — each furnace melts **270 kg**; heats required = total weight ÷ 270 (shown as decimal, e.g. 450 kg → 1.67 heats)
- **Saved groups** — save a load calculation as a named group with creation date, total weight, furnace heats, and full line-item breakdown
- **Offline-first** — all data stored in SQLite on device

## Furnace Heat Calculation

- **Furnace capacity:** 270 kg per heat
- **Formula:** `furnace heats = total weight (kg) ÷ 270`
- Displayed to 2 decimal places (e.g. 135 kg = 0.50 heats, 450 kg = 1.67 heats)
- Updates live as you add or remove parts in the calculator

## Saved Groups

After building a load in the calculator:

1. Tap **Save Group** and enter a name
2. Open **Saved Groups** from the home screen to browse all saved loads
3. Each group shows its name, total weight (kg), and **creation date**
4. Tap a group to view the full part-by-part breakdown
5. Delete groups you no longer need from the list menu

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
git tag v1.2.0
git push origin v1.2.0
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
├── models/         # Part, CalcLineItem, LoadGroup
├── providers/      # State management (provider)
├── repositories/   # Data access layer
├── services/       # Excel import
├── screens/        # UI screens
└── widgets/        # Reusable components
```

## License

Private project — all rights reserved unless otherwise specified.
