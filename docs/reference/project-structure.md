# Project structure

The app is a Flutter project. `lib/main.dart` loads configuration, checks the saved login session, and creates the root app.

| Path | Responsibility |
|---|---|
| `lib/auth/` | Onboarding, login, and registration screens. |
| `lib/utama/` | Signed-in dashboard, inventory, notifications, account pages, and company information. |
| `lib/pemeliharaan/` | SOP pages, QR scanning, inspection reports, and adding an item. |
| `lib/pemeliharaan/widgets/` | Inspection preview, scanner overlay, and APAR/Hydrant form fields. |
| `lib/model/` | JSON-backed user, inventory, item, and dashboard summary models. |
| `lib/config/` | Environment access through `Env.baseUrl`. |
| `lib/core/` | Shared colors and date formatting. |
| `lib/widgets/common/` | Shared section header, information dialog, and gradient button. |
| `test/` | Flutter widget tests. |
| `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` | Flutter platform runners and native project settings. |

Feature screens own most of their HTTP requests and loading/error state. Shared presentation widgets live beside their feature or under `lib/widgets/common/`.
