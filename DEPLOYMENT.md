# App Deployment Guide

Deploying a Flutter app to the App Store involves a few steps to prepare, build, and submit your application. Below is a high-level guide on how to deploy your Expense Tracker app to both the Apple App Store (iOS) and the Google Play Store (Android).

## 🍎 Apple App Store (iOS)

To deploy to the iOS App Store, you will need an Apple Developer account ($99/year) and Xcode installed on your Mac.

### 1. Register your App
- Log in to your [Apple Developer Account](https://developer.apple.com/) and create an **App ID** (Bundle Identifier, e.g., `com.yourname.expensetracker`).
- Go to [App Store Connect](https://appstoreconnect.apple.com/), create a **New App**, and link it to the App ID you just created.

### 2. Update Xcode Settings
- Open the `ios/Runner.xcworkspace` file in Xcode.
- In the **Signing & Capabilities** tab, select your development team and ensure your Bundle Identifier matches the one you registered.
- Update your App's **Display Name** and **Version/Build** numbers.

### 3. Add App Icons
- Generate your app icons for iOS and place them in the `ios/Runner/Assets.xcassets/AppIcon.appiconset` folder (You can use tools like [appicon.co](https://appicon.co/) or the `flutter_launcher_icons` package).

### 4. Create a Release Archive
- Run the following command in your terminal to build the iOS app:
  ```bash
  flutter build ipa
  ```
- This will generate an `.ipa` file located in `build/ios/ipa/`.

### 5. Upload and Submit
- Upload the generated `.ipa` file to App Store Connect using the **Transporter** app (available in the Mac App Store) or directly via Xcode (Window > Organizer).
- In App Store Connect, fill in all required app details, screenshots, description, and privacy policy.
- Choose the build you uploaded, submit it for review, and wait for Apple's approval!

---

## 🤖 Google Play Store (Android)

To deploy to Android, you will need a Google Play Developer account ($25 one-time fee).

### 1. Configure Package Details & App Name
- The package namespace has been updated to **`com.manojkchowdhury.expensetracker`** in `android/app/build.gradle.kts` and the Kotlin source files.
- The user-facing application name has been configured as `Expense Tracker` in `android/app/src/main/AndroidManifest.xml`.
- To update your app's version code and version name, modify the `version:` property in `pubspec.yaml` (e.g., `version: 1.0.0+1` where `1.0.0` is the user-facing version name and `1` is the internal build version code).

### 2. Create a Keystore (App Signing)
- Generate a secure upload keystore to digitally sign your app. In your terminal, run:
  ```bash
  keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
  *(Note: It is recommended to save this file inside the `android/app/` directory as it is already configured in `.gitignore` to prevent committing it to GitHub.)*

### 3. Configure Key Properties
- Create a file named `key.properties` in your `android/` directory. You can copy the template provided:
  ```bash
  cp android/key.properties.template android/key.properties
  ```
- Fill out the file with your chosen passwords and the path to your keystore:
  ```properties
  storePassword=YOUR_KEYSTORE_PASSWORD
  keyPassword=YOUR_KEY_PASSWORD
  keyAlias=upload
  storeFile=../app/upload-keystore.jks
  ```
- The project's Gradle configuration (`android/app/build.gradle.kts`) is already configured to automatically load `key.properties` and sign your production bundle. If `key.properties` is not present, it will gracefully fall back to debug signatures so local execution is never interrupted.

### 4. Build the Android App Bundle (AAB)
- Run the following command in your terminal to compile the production-ready Android App Bundle (`.aab`):
  ```bash
  flutter build appbundle
  ```
- The generated bundle will be located at:
  `build/app/outputs/bundle/release/app-release.aab`

### 5. Upload to Google Play Console
1. Go to the [Google Play Console](https://play.google.com/console/) and sign in.
2. Click **Create app** and complete the initial setup (App name, language, app/game, free/paid, declarations).
3. Complete the **Initial App Setup Dashboard** (Set up privacy policy, content rating, target audience, dashboard category, store listing with description, screenshots, and custom graphics).
4. Navigate to the **Production** track (under Release in the sidebar).
5. Click **Create new release**, opt in to Google Play App Signing (recommended), and upload the generated `app-release.aab` file.
6. Review the release warnings/details, click **Save**, and then click **Start rollout to Production**!

