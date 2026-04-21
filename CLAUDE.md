# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                          # Install dependencies
flutter analyze                          # Static analysis / lint
flutter test                             # Run tests
flutter test test/widget_test.dart       # Run a single test file
flutter build appbundle --release        # Build Android AAB (release)
flutter build apk --debug                # Build Android APK (debug)
flutter pub run flutter_launcher_icons   # Regenerate app icons from newIcon.png
```

## Architecture

FanArena is a Flutter mobile app (iOS/Android) for sports fans to track teams, matches, predictions, and journal entries. All data is stored locally — there is no backend.

**State management:** Single `AppDataProvider` (Provider package) wraps all app state. Screens read and mutate data exclusively through this provider.

**Persistence:** `StorageService` (`lib/services/storage_service.dart`) serializes everything to SharedPreferences as JSON. Each feature has its own key. Schema versioning is at v1. All models implement `toJson()` / `fromJson()`.

**Routing:** Defined in `lib/app.dart` as named routes. Entry point is `lib/main.dart`, which initializes `StorageService` before `runApp`.

**Core models** (`lib/models/`): `TeamItem`, `MatchPlan`, `PredictionItem`, `JournalEntry`, `TournamentItem`, `UserProfile`.

**Screens** (`lib/screens/`): Organized by feature — `home/`, `teams/`, `planner/`, `predictions/`, `journal/`, `tournaments/`, `stats/`, `settings/`, `onboarding/`.

**Theme:** Light/dark support via `lib/core/theme/`. Colors in `app_colors.dart`, spacing constants in `app_spacing.dart`.

## Debug Overlay

`lib/widgets/debug_overlay.dart` — полупрозрачная полоска поверх UI (только в debug-сборках), отображает два статуса в реальном времени:

**Статус зарядки** — использует пакет `battery_plus`. Подписывается на `Battery.onBatteryStateChanged` и показывает одно из состояний: `Charging`, `Full`, `Connected` (подключён, но не заряжается), `Battery` (разряжается). Иконка меняется в зависимости от состояния.

**USB-отладка** — проверяет `Settings.Global.ADB_ENABLED` через нативный MethodChannel `com.dimakrash.fanarena/debug_info`. Нативная сторона реализована в `android/app/src/main/kotlin/.../MainActivity.kt` (метод `isUsbDebuggingEnabled`). Когда ADB включён — индикатор зелёный, иначе серый.

Оверлей подключён в `lib/app.dart` как `Positioned`-виджет поверх стека. На iOS вызов нативного метода тихо игнорируется (`PlatformException` перехватывается).

## CI/CD

GitHub Actions (`.github/workflows/main.yml`) triggers on push to `main`. It builds a signed AAB and a debug APK, uploading both as artifacts. Signing credentials come from repository secrets (`KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`, `KEYSTORE_BASE64`). The keystore file is `upload-keystore.jks` (not committed).
