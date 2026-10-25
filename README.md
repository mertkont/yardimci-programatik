# Yardımcı Programatik (Programmatic Assistant)

An offline Android app for programmatic ad traders to track campaigns, pacing, and
profit, and to work out media math on the go. The UI is bilingual (English / Turkish)
and follows the device language, which you can also switch in Settings.

## Features

- **Today**: a daily brief of active campaigns, spend, profit, and anything that needs attention.
- **Campaigns**: create and edit campaigns (CPM, vCPM, CPV, CPCV, CPC, CPA, ROAS, Flat) with budgets,
  flight dates, margins, and status. Log daily delivery and view trends, history, and attached files.
- **Pacing and profit**: expected vs. actual spend, under/over-pacing alerts, the projected date the
  budget runs out, and margin calculated on spend or on the client budget.
- **Calculators**: two-way solvers for CPM, CTR, CPV, CPCV, CPV (ThruPlay), CPC, CPA, vCPM, VCR,
  viewability, and ROAS. Fill in any two fields and the empty one is calculated.
  For example, enter a budget and a CPM of 20 to get the impression goal.
- **Guides**: a searchable knowledge base of programmatic terms and metrics.
- **Notifications**: an optional daily summary notification.
- **Backup**: export and restore all data as a `.zip` file.
- Light and dark themes, plus a configurable currency symbol.

All data stays on the device in a local SQLite database.

## Building

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.11`).

```bash
flutter pub get
flutter run                 # run on a connected device or emulator
flutter build apk --release # build/app/outputs/flutter-apk/app-release.apk
```

## Project structure

```
lib/
  db/        SQLite database and knowledge-base seed data
  l10n/      Lightweight EN/TR localization
  models/    Campaign and daily-metric models
  screens/   App screens (today, campaigns, calculators, guides, settings, backup)
  services/  Notifications, daily summary, backup, settings
  utils/     Metric calculations and formatting
  widgets/   Shared UI components and charts
```

## License

GPL-3.0. See [LICENSE](LICENSE).
