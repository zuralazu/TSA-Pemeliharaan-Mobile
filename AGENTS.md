<!-- SETUP-AGENT-FIRST:START -->
# Agent instructions

At the start of every task, read this file before inspecting or changing project files. Treat it as the first and authoritative project guide. Then use [`docs/README.md`](docs/README.md) to find relevant project documentation.

## Project commands

- Install dependencies: `flutter pub get`
- Analyze Dart code: `flutter analyze --no-fatal-infos --no-fatal-warnings`
- Run widget tests: `flutter test`
- Launch the Android emulator used by this project: `flutter emulators --launch Pixel_8_API_35`
- Run the app: `flutter run`
- In the active `flutter run` terminal, press `r` for hot reload, `R` for hot restart, or `q` to stop.

The app loads `.env` at startup. Copy `.env.example` to `.env` and set `LOCAL_SERVER` before using pages that call the backend. Do not put credentials or private keys in `.env`; Flutter bundles it as an app asset.

The analyzer currently reports existing info and warning diagnostics. The project check command prints them without failing on them; analyzer errors still fail.

Debug builds install an `HttpOverrides` that accepts every TLS certificate. Profile and release builds must use normal certificate checks.

## Documentation

Keep [`docs/README.md`](docs/README.md) and this file's documentation table in sync when adding, moving, or deleting project docs. Read the relevant how-to, reference, or explanation doc before changing the flow it describes.

| Document | Purpose |
|---|---|
| [Run the app](docs/how-to/run-app.md) | Start the Android emulator and preview the Flutter app. |
| [Project structure](docs/reference/project-structure.md) | Find the source area that owns each feature. |
| [Environment configuration](docs/reference/environment.md) | Configure `LOCAL_SERVER` for local development. |
| [Domain model](docs/explanation/domain-model.md) | Understand the app's models and feature areas. |
| [App flows](docs/explanation/app-flows.md) | Trace login, dashboard, inventory, and inspection flows. |
| [Setup Agent First skill](docs/explanation/setup-agent-first-skill.md) | Read the setup skill included in `.agents`. |
| [First-run onboarding design](docs/superpowers/specs/2026-11-06-onboarding-design.md) | Review the proposed first-run introduction. |
| [First-run onboarding implementation plan](docs/superpowers/plans/2026-11-06-first-run-onboarding.md) | Track the implementation steps for the introduction. |
| [Company registration design](docs/superpowers/specs/2026-11-06-company-registration-design.md) | Review company profile registration and API assumptions. |
| [Company registration implementation plan](docs/superpowers/plans/2026-11-06-company-registration.md) | Track the registration form, request, and navigation changes. |
| [Launch screen assets](docs/reference/ios-launch-image-assets.md) | Find the canonical iOS launch-image instructions. |
| [ADR convention](docs/adr/README.md) | Record approved architecture decisions. |
| [Contributing](CONTRIBUTING.md) | Set up the project and make a change. |

## Architecture Decision Records (ADRs)

`docs/adr/` holds short, append-only records of why a structural choice was made. **Never create an ADR unprompted.** When a change is a new cross-cutting convention, a data-model seam, a package-boundary change, an auth/isolation invariant, or a choice between competing approaches where a viable alternative was rejected for real reasons, stop and ask the user whether they want one. Create it only if they say yes. Name files `NNNN-kebab-title.md`, with a zero-padded number next after the highest existing file. Use these sections: Context, Decision, Alternatives Considered (one `###` subheading per rejected option with Pros, Cons, and Rejected), and Consequences. Never rewrite a past ADR. Record a reversal in a new ADR that supersedes the old one, update the old file's status to `Superseded by NNNN`, and leave the file in place.
<!-- SETUP-AGENT-FIRST:END -->
