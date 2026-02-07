# Run Flutter app on Android (live changes / hot reload)

## Fix: "adb is not recognized"

ADB (Android Debug Bridge) is in the **Android SDK**. Add it to your PATH.

### 1. Find your Android SDK path

Common locations on Windows:
- **Android Studio default:** `C:\Users\<YourUsername>\AppData\Local\Android\Sdk`
- Or run in PowerShell: `echo $env:LOCALAPPDATA\Android\Sdk`

### 2. Add platform-tools to PATH (PowerShell – current session)

```powershell
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path += ";$sdkPath\platform-tools"
adb devices
```

If `adb devices` works, your device should appear when the phone is connected via USB with **USB debugging** enabled.

### 3. Add to PATH permanently (so you don’t have to do step 2 every time)

1. Press **Win**, type **environment variables**, open **Edit the system environment variables**.
2. Click **Environment Variables**.
3. Under **User variables**, select **Path** → **Edit** → **New**.
4. Add: `C:\Users\<YourUsername>\AppData\Local\Android\Sdk\platform-tools`  
   (replace `<YourUsername>` with your Windows username, or use the path from step 1).
5. Confirm with **OK**, then **close and reopen** your terminal/Cursor.

### 4. On your Android phone

1. Enable **Developer options**: Settings → About phone → tap **Build number** 7 times.
2. In **Developer options**, turn on **USB debugging**.
3. Connect the phone with a USB cable.
4. If prompted on the phone, allow **USB debugging** for this computer.

### 5. Run the app with live changes

In the project folder (e.g. `frontend`):

```powershell
cd "c:\Users\h\Desktop\my work\weasy\frontend"
flutter devices
flutter run
```

- Use **r** in the terminal for hot reload.
- Use **R** for hot restart.

If Android SDK is missing, install **Android Studio** and complete the SDK setup, then run `flutter doctor` and fix any issues it reports.
