# Mahakhanij Consumer App 2.0 — Flutter Production Codebase

Welcome to the **Mahakhanij Consumer App 2.0** production-ready Flutter codebase. This project has been engineered with **Clean Architecture**, **Flutter Riverpod (v2.5+)**, **GoRouter (v14+)**, and a design token system directly matching the Maharashtra Minor Mineral portal requirements.

---

## 1. Running in Android Studio IDE

The project has been pre-configured with native Android wrappers (`android/`), Android Studio module files (`.idea/`), and pre-set Run Configurations so it opens cleanly without any missing project facet errors.

### Step-by-Step in Android Studio:
1. **Open Project**:
   - Launch **Android Studio**.
   - Click **File** → **Open...** (or "Open" on the welcome screen).
   - Select the `flutter_app` folder and click **OK**.
2. **Flutter & Dart Plugins**:
   - Ensure the official **Flutter** and **Dart** plugins are installed in Android Studio (Settings → Plugins).
3. **Fetch Packages**:
   - Android Studio will show a blue prompt: *"Flutter commands: 'flutter pub get'"*.
   - Click **'Pub get'** (or run `flutter pub get` in the built-in terminal).
4. **Launch on Emulator / Physical Device**:
   - Select an Android Virtual Device (AVD Emulator) or connect your physical phone via USB.
   - The Run Configuration dropdown at the top toolbar will already be set to `main.dart`.
   - Click the **Green Run (Play) Button** (`Shift + F10`).
   - The app will compile Gradle, launch the APK, and enable Hot Reload / Hot Restart.

---

## 2. Terminal Quick Start (CLI)

```bash
# 1. Navigate to the flutter app folder
cd flutter_app

# 2. Get dependencies
flutter pub get

# 3. Run the app on a connected phone or emulator
flutter run
```

---

## 2. Architecture & Directory Overview

```
lib/
├── main.dart                       # App entrypoint with ProviderScope & orientation locks
├── app.dart                        # MaterialApp.router with AppTheme and AppRouter
├── core/
│   ├── config/app_config.dart      # Environment config (useMockData toggle, apiBaseUrl)
│   ├── constants/app_colors.dart   # Design tokens from tokens.css (#1241a6, #dde3ee, etc.)
│   ├── network/                    # Dio client with JWT bearer token interceptors & endpoints
│   ├── router/app_router.dart      # GoRouter tree with StatefulShellRoute (Tabs) & subroutes
│   └── theme/app_theme.dart        # Material 3 ThemeData with GoogleFonts (Plus Jakarta Sans)
├── domain/                         # Immutable entity models with JSON serialization
│   ├── common.dart                 # GeoPoint, Address, Money, Quantity
│   ├── user.dart                   # User, UserType (ORGANIZATION, NORMAL_CONSUMER, SUPERVISOR)
│   ├── organization.dart           # Organization, Project, Package, SupervisorInfo
│   ├── mineral.dart                # Mineral, StockPoint
│   ├── order.dart                  # Order, OrderStatus
│   ├── delivery.dart               # TransportPermit (DigiTP), Vehicle, DiscrepancyReport
│   ├── inventory.dart              # InventoryBalance, ConsumptionEntry
│   └── temporary_excavation.dart   # TemporaryExcavationApplication, DemandNote, ExcavationOrder
├── rules/                          # Pure business rules & statutory calculations
│   ├── access_control.dart         # Role-based capability checks
│   ├── excavation_rules.dart       # Fee slab calculations (₹500/₹2000/₹5000 + ₹20 stamp duty) & step validation
│   └── inventory_rules.dart        # Drawdown volume validation against active balances
├── data/
│   ├── mock_db.dart                # Complete offline seed database with realistic Mahakhanij fixtures
│   └── repositories/               # Abstract repository contracts with pluggable implementations
├── shared/widgets/                 # Core Design System widgets (AppButton, AppCard, PrototypeBar, HomeHeader, DeliverySummaryCard, etc.)
└── features/                       # Riverpod providers & UI Screens
    ├── auth/                       # SplashScreen, WelcomeScreen, LoginScreen, RegisterScreen, OtpScreen, PersonaSwitchScreen
    ├── shell/                      # MainShellScreen with top PrototypeBar and role-based bottom navigation
    ├── home/                       # HomeScreen with institutional Navy header (#102d5e), stat cards & quick services
    ├── activity/                   # ConsumerActivityScreen (Enquiries, Live Deliveries, Delivered chips & DigiTP modal)
    ├── excavation/                 # TemporaryExcavationScreen, NewApplicationWizard (5 steps), ResumeDraftDialog
    ├── orders/                     # OrdersScreen, OrderDetailsScreen, DigitpPassScreen, LiveVehicleTrackingScreen
    ├── receiving/                  # ReceiveScreen (gate arrivals & en route), ReceiveDeliveryScreen, DigitpScanScreen
    ├── inventory/                  # InventoryScreen, RecordConsumptionDialog
    ├── organization/               # ProjectsScreen, CreateProjectScreen, SupervisorsScreen
    ├── minerals/                   # MineralCatalogScreen, StockPointMapScreen
    ├── more/                       # MoreScreen (Profile & KYC on top, role-specific operations, sign out)
    └── profile/                    # ProfileScreen with KYC verification badges
```

---

## 3. Switching From Mock Data to Live REST Backend

In `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  /// Set to false when ready to connect to live API endpoints
  static const bool useMockData = false;

  /// Update to your staging or production API domain
  static const String apiBaseUrl = 'https://api.mahakhanij.gov.in/api/v1';
}
```

The REST API endpoints defined in `lib/core/network/api_endpoints.dart` match **Section 6.1 of DEVELOPER_HANDOFF.md**:
- `POST /auth/otp/send` & `POST /auth/otp/verify`
- `GET /organizations/:id/projects`
- `POST /excavation/applications` & `POST /excavation/drafts`
- `POST /deliveries/verify-qr` & `POST /deliveries/:id/receive`
- `POST /inventory/:id/consume`

---

## 4. Key Workflows Implemented

### A. 5-Step Statutory Temporary Excavation Wizard (`/excavation/new`)
- **Step 1 — Applicant Details**: Auto-filled from session, PAN format validator (`[A-Z]{5}[0-9]{4}[A-Z]{1}`), phone validation.
- **Step 2 — Excavation Parameters**: Mineral selection, volume in Brass, semi-mechanized method selection.
- **Step 3 — Quarry Location**: Village, survey/gat number, private/government land type, site GPS coordinates.
- **Step 4 — Compliance Checklist**: 7/12 Land extract upload, Gram Panchayat NOC, ID proof.
- **Step 5 — Fee Calculation & Declaration**: Dynamically computes fee slab based on volume + ₹20 statutory stamp duty.
- **Auto-Saving Draft Memory**: Real-time auto-saves draft state to `SharedPreferences`. Returning users get a resume prompt taking them to their exact step.

### B. DigiTP QR Receiving & Discrepancy Reporting (`/receiving`)
- Uses `mobile_scanner` to scan camera QR codes.
- Compares permitted volume against physical manifest.
- Option to confirm 100% legal receipt (`RECEIVED`) or log shortage report (`RECEIVED_WITH_DISCREPANCY`).

### C. On-Site Inventory Drawdowns (`/inventory`)
- Real-time balances per package site.
- Legal sourcing badge asserting 100% compliance.
- Daily drawdown modal preventing negative stock.

---

## 5. Deployment Checklist for App Stores

### Android (Google Play Store)
1. **Keystore Signing**:
   - Generate `upload-keystore.jks` using `keytool`.
   - Configure `android/key.properties` and reference it in `android/app/build.gradle`.
2. **Permissions**:
   - `android/app/src/main/AndroidManifest.xml` already has `<uses-permission android:name="android.permission.CAMERA" />` for QR scanning.
3. **Build Bundle**:
   ```bash
   flutter build appbundle --release
   ```

### iOS (Apple App Store)
1. In `ios/Runner/Info.plist`, ensure camera permission string is present:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Mahakhanij requires camera access to scan DigiTP e-Pass QR codes.</string>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Mahakhanij requires location access to capture excavation site coordinates.</string>
   ```
2. **Build Archive**:
   ```bash
   flutter build ipa --release
   ```
