# First-run onboarding implementation plan

> **For agentic workers:** Use `superpowers:executing-plans` to implement this plan task by task. Follow the test-first steps.

**Goal:** Add a one-time animated introduction, three feature slides, and Register/Login actions for new APK Tracker users.

**Architecture:** Keep the session check in `AplikasiSaya`. Add an intro-completed flag in `SharedPreferences`, a focused `IntroOnboardingPage` with `PageView`, and keep `OnboardingPage` as the returning Register/Login entry. Bundle one local Lottie JSON asset.

**Tech Stack:** Flutter/Dart (`^3.8.0`), `shared_preferences`, `PageView`, and `lottie: ^3.3.1`.

**Spec:** [First-run onboarding design](../specs/2026-11-06-onboarding-design.md)

## Global Constraints

- Show the intro once after installation, when no valid user session exists and `intro_seen` is false.
- Keep valid user sessions on the existing dashboard.
- The final slide has Register and Login buttons. Save `intro_seen` before navigating.
- Later unauthenticated launches show both Register and Login buttons on the entry page.
- Keep the Lottie animation local. Do not add remote loading or new API behavior.

## Review Focus

- A valid saved session must still open the dashboard.
- An expired session must clear the same keys and respect `intro_seen`.
- A first-run installation with no session must show the animated intro.
- Completing the final page must persist `intro_seen` before navigating to either route.
- Long copy and small emulator viewport must not hide the final actions or overflow.

---

### Task 1: Build the first-run intro and auth entry

**Files:**
- Modify: `test/widget_test.dart`
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Modify: `lib/auth/onboarding_page.dart`
- Create: `lib/auth/intro_onboarding_page.dart`
- Create: `assets/animations/onboarding_scan.json`
- Modify: `docs/explanation/app-flows.md`

**Interfaces:**
- Consumes: Existing named routes `/register`, `/login`, and `/dashboard`; existing `SharedPreferences` session keys.
- Produces: `IntroOnboardingPage`, `intro_seen` in `SharedPreferences`, and the later-launch Register/Login entry.

- [x] Write widget tests for first launch showing the intro, later launch showing both auth actions, final-slide route choices, and the intro flag being saved.
- [x] Run `flutter test test/widget_test.dart` and confirm the new first-run and action assertions fail against the current one-screen login UI.
- [x] Add `lottie: ^3.3.1`, register `assets/animations/onboarding_scan.json`, and build a local vector animation of the APK Tracker fire icon with a QR scan line.
- [x] Add `IntroOnboardingPage` with four pages: animated welcome, APAR/Hydrant inventory, QR inspection, and inspection reports. Add page indicators and a Next action. Put Register and Login buttons on the last page.
- [x] Update `AplikasiSaya._cekLoginStatus` to preserve its current valid-session and expiration behavior, then route unauthenticated first launches to `IntroOnboardingPage` and later launches to `OnboardingPage` using `intro_seen`.
- [x] Update `OnboardingPage` to show Register and Login buttons for later unauthenticated launches. Save `intro_seen` before either intro CTA navigates.
- [x] Run `flutter test test/widget_test.dart` and confirm all onboarding assertions pass.
- [x] Run `flutter analyze --no-fatal-infos --no-fatal-warnings`.
- [x] Update `docs/explanation/app-flows.md` with the first-run and return-launch paths.

### Task 2: Verify docs and emulator preview

**Files:**
- Modify: `docs/README.md`
- Modify: `AGENTS.md`
- Test: `scripts/check_docs_index.py`

**Interfaces:**
- Consumes: `IntroOnboardingPage` and `intro_seen` from Task 1.
- Produces: Indexed documentation that describes the shipped onboarding flow.

- [x] Run `python scripts/check_docs_index.py` and confirm the docs index and `AGENTS.md` list the same pages.
- [x] Run the app on `Pixel_8_API_35` and inspect all four slides, including the final Register/Login actions.

