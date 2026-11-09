# First-run onboarding design

## Intent

Give a new APK Tracker user a short, animated introduction to the app before they register or log in.

## Goals

- Play a local Lottie animation on the first intro page.
- Explain inventory, QR inspection, and report history in three swipeable pages.
- Show Register and Login actions on the final page.
- Show the intro once per installation. Later unauthenticated launches go to the Register/Login page.
- Keep valid logged-in sessions on the existing dashboard route.

## Non-goals

- Change login or registration API behavior.
- Add remote animation loading or analytics.
- Reorganize unrelated screens or app folders.

## Approaches

- Extend the existing page with Flutter's built-in animations. This adds no dependency, but limits the requested animated illustration to the current icon.
- Add a small local Lottie animation and use Flutter's existing `PageView` for the feature slides. This adds one animation dependency and asset, and supports the selected visual direction. **Selected.**
- Show the current static entry page only. This would not provide the requested feature slides.

## Behavior

`AplikasiSaya` keeps its valid-session check. When no valid session exists, it checks a `SharedPreferences` intro-completed flag. If the flag is false, it shows the new intro flow. If the flag is true, it shows the Register/Login entry page.

The intro has four pages: an animated welcome, inventory, QR inspection, and reports. The last page contains Register and Login buttons. Completing the flow or selecting Skip saves the flag. Each button uses the existing `/register` or `/login` route.

The Lottie file is local and bundled with the app. It does not load over the network. The existing blue palette and fire-protection icon style guide the animation and pages.

## Constraints

- Reuse `SharedPreferences`, named routes, and Flutter's built-in `PageView`.
- Do not add secrets to `.env` or the animation asset.
- Preserve the existing dashboard route for valid sessions.

## Verification

- Widget tests cover first launch, saved completion, and the final Register/Login actions.
- Run the app on `Pixel_8_API_35` and inspect the animation and slides in the emulator.
