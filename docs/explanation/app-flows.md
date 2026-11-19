# App flows

## Startup and login

`main()` loads `.env` and starts `AplikasiSaya`. The root widget reads `user_data` and `login_timestamp` from `SharedPreferences`. A session younger than 15 minutes opens `DasborHalaman`; otherwise, the app clears expired session keys and checks `intro_seen`. A new unauthenticated installation sees a four-page introduction with a local Lottie fire and QR scan animation, equipment inventory, QR inspections, and inspection reports. The last page offers Register and Login. Choosing either action or skipping the intro stores `intro_seen`; later unauthenticated launches open the Register/Login entry page directly. Register collects the company's identity and logo in the first step, then supervisor credentials in the second, and submits multipart data to `${Env.baseUrl}/api/register` with the `supervisor_umum` role. A successful registration returns to Login. Login and Register each link to the other. Login posts credentials to the backend, stores the returned user and token, and opens the dashboard.

## Dashboard and inventory

The dashboard loads the saved user and requests the equipment summary. Its bottom navigation switches between the dashboard, inventory, and account views. Other navigation slots open QR scanning and the SOP module pages. The inventory list requests `/api/barangs`, filters by name or identification number, and opens an item detail page. The detail page loads equipment data and the latest inspection.

## QR inspection

The scanner reads an equipment identifier, checks the saved role, and requests the matching item. The preview offers inspection only when the backend says the inspection is due. The report form loads the latest report and submits the common report fields, APAR or Hydrant fields, and an optional photo as multipart data. On success, it returns to the dashboard.

The SOP module pages are a separate reference flow. They show hard-coded APAR or Hydrant steps and do not submit inspection reports.

## Development-only transport behavior

`lib/main.dart` accepts invalid TLS certificates through `MyHttpOverrides` only in debug builds. Profile and release builds use the normal certificate checks.
