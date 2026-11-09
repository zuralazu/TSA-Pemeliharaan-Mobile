# Contribute to APK Tracker

## Prerequisites

- Install Flutter with a bundled Dart SDK that satisfies the `^3.8.0` constraint in `pubspec.yaml`.
- Install Android Studio and an Android SDK emulator.
- Copy `.env.example` to `.env` and set `LOCAL_SERVER`. See [environment configuration](docs/reference/environment.md).

## Install dependencies

Copy the local environment template first:

```powershell
Copy-Item .env.example .env
```

Set `LOCAL_SERVER` in `.env`, then install the Dart dependencies:

```powershell
flutter pub get
```

## Run the app

Start the configured emulator and app:

```powershell
flutter emulators --launch Pixel_8_API_35
flutter run
```

Keep the `flutter run` terminal open. Press `r` to hot reload, `R` to hot restart, or `q` to stop. See [how to run the app](docs/how-to/run-app.md) for device selection.

## Check a change

Run the analyzer and widget tests before opening a change:

```powershell
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

The GitHub workflow runs these commands and checks the docs index.

## Work with an agent

Every agent task starts by reading [`AGENTS.md`](AGENTS.md). That file links to the project guides and requires agents to use it as the first project reference.

Examples:

- "Trace how login stores the session before changing authentication."
- "Add the inventory empty state and update the relevant widget test."
- "Add a Hydrant inspection field and follow the existing APAR/Hydrant form flow."
