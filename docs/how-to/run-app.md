# Run the app in an Android emulator

1. Install Flutter and Android Studio. Configure an Android emulator in Android Studio's Device Manager.
2. Copy `.env.example` to `.env` and set `LOCAL_SERVER` to your backend address.

   ```powershell
   Copy-Item .env.example .env
   ```

3. From the project root, install the Dart dependencies:

   ```powershell
   flutter pub get
   ```

4. Start this project's emulator:

   ```powershell
   flutter emulators --launch Pixel_8_API_35
   ```

5. Confirm that Flutter sees the emulator:

   ```powershell
   flutter devices
   ```

6. Start the app:

   ```powershell
   flutter run
   ```

Flutter installs and opens the app on the selected device. Keep the `flutter run` terminal open while you work.

To apply Dart changes, press `r` in that terminal for hot reload. Press uppercase `R` for hot restart if a change needs the app to restart. Press `q` to stop the app.

If more than one device is available, pass the emulator's ID to `flutter run -d <device-id>`.
