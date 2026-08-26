# PricePilot Bill

PricePilot Bill is a Flutter-based business billing workspace for managing invoices, inventory, customers, cash and bank activity, and reports.

## Features

- Responsive Material 3 dashboard
- Overview dashboard with sales metrics and chart
- Invoice listing and invoice creation dialog
- Inventory and product tracking
- Customer management view
- Cash and bank overview
- Reports and analytics cards
- Desktop sidebar navigation
- Mobile navigation drawer
- Inter typography through Google Fonts

## Tech Stack

- Flutter
- Dart 3.x
- Material 3
- Provider (configured for state management)
- GoRouter (configured for navigation)
- SQLite via `sqflite` (configured for local persistence)
- `shared_preferences` for preferences
- `fl_chart` and custom painting for charts
- `google_fonts` for typography
- `flutter_svg`, `cached_network_image`, and `flutter_animate` for media and UI support

## Requirements

- Flutter SDK with Dart 3.x support
- Chrome, Windows, or another Flutter-supported target

Check the local setup with:

```bash
flutter doctor
flutter devices
```

## Run Locally

From this directory:

```bash
flutter pub get
flutter run -d chrome
```

To run the desktop build on Windows:

```bash
flutter run -d windows
```

Run static analysis with:

```bash
flutter analyze
```

Run tests with:

```bash
flutter test
```

## Project Structure

```text
lib/
  main.dart             Active application entry point and UI
Pages/
  *.txt                 Page design/reference exports
Components/             Component resources
Pubspec/                Supporting project resources
pubspec.yaml            Dependencies and Flutter configuration
```

## Current Status

The active application is implemented as a self-contained Flutter UI in `lib/main.dart`. The page files under `Pages/` contain FlutterFlow-style design references and are not currently imported by the running application. Data is currently sample content; backend services, authentication, and production data synchronization are not connected yet.
