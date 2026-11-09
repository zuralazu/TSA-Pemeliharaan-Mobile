# Environment configuration

The app reads its backend URL from the `LOCAL_SERVER` key in the root `.env` file. `lib/main.dart` loads that file before calling `runApp`, and `lib/config/env.dart` exposes the value as `Env.baseUrl`.

Copy `.env.example` to `.env`, then set `LOCAL_SERVER` to the backend address reachable from the emulator. Keep `.env` local. Git ignores it.

The Dart code currently reads `LOCAL_SERVER` for backend endpoints, including registration and adding equipment. `DEV_BASE_URL` and `PROD_BASE_URL` are retained in `.env.example` for your environment workflow, but the app does not select them automatically yet.

For an Android emulator, `localhost` points to the emulator itself, not the development computer. Use the host address configured for your local backend.

The root `pubspec.yaml` declares `.env` as a Flutter asset. App assets can be extracted from a built app, so do not put passwords, API keys, or other private credentials in this file. `.env.example` lists the supported keys without values.

