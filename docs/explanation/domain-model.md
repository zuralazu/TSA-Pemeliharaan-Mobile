# App domain and data model

APK Tracker manages fire-protection equipment and its inspection reports. APAR and Hydrant equipment share inventory and inspection flows, with type-specific fields in the report form.

## Feature areas

| Area | What it owns |
|---|---|
| `auth` | Onboarding, login, and account registration. Login stores the returned user and token in `SharedPreferences`. |
| `utama` | The signed-in app: dashboard summary, inventory list and detail, notifications, account management, and company information. |
| `pemeliharaan` | Static SOP guidance, QR-based item lookup, due-date preview, inspection reports, and adding inventory. |
| `model` | JSON conversions for `User`, `InventoryItem`, `Barang`, `RingkasanDashboard`, and its type subtotals. |
| `config` | `Env.baseUrl`, read from the `LOCAL_SERVER` dotenv key. |
| `core` | Shared color constants and date formatting helpers. |
| `widgets` | Common section heading, information dialog, and gradient button. |

`lib/main.dart` owns app startup and the initial session check. A stored session opens the dashboard if its login timestamp is less than 15 minutes old. Otherwise, startup clears expired session data and shows onboarding.

## Equipment and inspections

The QR flow reads an equipment identifier and requests its item data. APAR and Hydrant items open a preview. The user can continue only when the backend marks the inspection as due. The report form loads the last report, then submits shared fields and equipment-specific fields. It can also attach a photo.

`InventoryItem` represents rows in the inventory list. `Barang` maps a wider equipment record. `RingkasanDashboard` represents the dashboard totals and optional APAR and Hydrant subtotals. These are JSON models, not a local database schema.

## Session and API access

Screens make HTTP requests directly. They read the bearer token from `SharedPreferences` and generally build the request URL from `Env.baseUrl`. Registration is an exception and currently has its own hard-coded backend URL. Error and missing-token handling varies between screens.
