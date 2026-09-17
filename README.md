# ResQnet — Community Emergency Assistance Application

**ResQnet** is a community emergency assistance mobile application built with Flutter (Material 3, English + Tamil localization), native Android Kotlin integration (high-priority emergency notification channels & bridges), and a FastAPI backend with PostgreSQL/PostGIS spatial radius search, JWT authentication, and privacy-first nearby safety aggregation.

---

## Table of Contents
1. [Required Software](#1-required-software)
2. [Flutter Installation](#2-flutter-installation)
3. [Android Studio Setup](#3-android-studio-setup)
4. [Python Installation](#4-python-installation)
5. [PostgreSQL Installation](#5-postgresql-installation)
6. [PostGIS Setup](#6-postgis-setup)
7. [FastAPI Setup](#7-fastapi-setup)
8. [Database Migration](#8-database-migration)
9. [Firebase Setup](#9-firebase-setup)
10. [Firebase Cloud Messaging (FCM) Setup](#10-firebase-cloud-messaging-fcm-setup)
11. [Google Maps Setup](#11-google-maps-setup)
12. [Kotlin Native Integration](#12-kotlin-native-integration)
13. [Environment Variables](#13-environment-variables)
14. [Running the Backend](#14-running-the-backend)
15. [Running the Flutter App](#15-running-the-flutter-app)
16. [Testing on Android](#16-testing-on-android)
17. [Building APK](#17-building-apk)
18. [Building AAB (App Bundle)](#18-building-aab-app-bundle)
19. [Backend Deployment (Docker & Compose)](#19-backend-deployment-docker--compose)
20. [Production Configuration & Security](#20-production-configuration--security)

---

## 1. Required Software
- **Flutter SDK**: 3.24+ (Dart 3.5+)
- **Android Studio**: Koala / Ladybug or later with Android SDK 34 and Command-line Tools
- **JDK**: Java Development Kit 17 (OpenJDK 17 recommended)
- **Python**: 3.10+ (Python 3.11/3.12/3.14 compatible)
- **PostgreSQL**: Version 15 or 16
- **PostGIS Extension**: 3.3 or 3.4
- **Docker & Docker Compose** (optional for containerized deployment)
- **Git**

---

## 2. Flutter Installation
1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install).
2. Extract the archive to a clean directory (e.g., `C:\src\flutter` on Windows or `/opt/flutter` on macOS/Linux).
3. Add the `bin` directory to your system `PATH`:
   - Windows: System Properties → Environment Variables → Path → Add `C:\src\flutter\bin`.
4. Open a new terminal and verify the installation:
   ```bash
   flutter doctor
   ```
5. Resolve any missing dependencies reported by `flutter doctor`.

---

## 3. Android Studio Setup
1. Download and install [Android Studio](https://developer.android.com/studio).
2. Open Android Studio → **SDK Manager** (Settings → Languages & Frameworks → Android SDK).
   - Under **SDK Platforms**: Install **Android 14 (API 34)**.
   - Under **SDK Tools**: Check and install:
     - Android SDK Build-Tools 34
     - Android SDK Command-line Tools (latest)
     - Android Emulator
3. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```
4. Create an Android Virtual Device (AVD) using Device Manager (e.g., Pixel 7 running API 34).

---

## 4. Python Installation
1. Download Python 3.11+ from [python.org](https://www.python.org/downloads/).
2. On Windows, make sure to check **"Add python.exe to PATH"** during installation.
3. Verify installation:
   ```bash
   python --version
   pip --version
   ```

---

## 5. PostgreSQL Installation
### Option A: Local Installation
1. Download PostgreSQL installer from [enterprisedb.com/downloads/postgres-postgresql-downloads](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads).
2. During installation, note down the superuser password (e.g., `postgres`).
3. Port: `5432` (default).

### Option B: Docker
```bash
docker run --name resqnet-postgis -e POSTGRES_USER=resqnet -e POSTGRES_PASSWORD=resqnet_secret -e POSTGRES_DB=resqnet_db -p 5432:5432 -d postgis/postgis:16-3.4
```

---

## 6. PostGIS Setup
1. Connect to PostgreSQL using `psql` or pgAdmin:
   ```sql
   CREATE DATABASE resqnet_db;
   \c resqnet_db;
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```
2. Verify PostGIS is active:
   ```sql
   SELECT PostGIS_Version();
   ```

---

## 7. FastAPI Setup
1. Navigate to the `backend/` directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   # Windows
   python -m venv venv
   .\venv\Scripts\activate

   # macOS / Linux
   python3 -m venv venv
   source venv/bin/activate
   ```
3. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

---

## 8. Database Migration
1. Copy the environment file template:
   ```bash
   cp .env.example .env
   ```
2. Update `.env` with your PostgreSQL connection URL.
3. Run Alembic migrations:
   ```bash
   alembic upgrade head
   ```

---

## 9. Firebase Setup
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it `ResQnet`.
3. Add an Android app to the project:
   - Android package name: `com.resqnet.resqnet`
   - App nickname: `ResQnet`
4. Download `google-services.json` and place it into `android/app/google-services.json`.

---

## 10. Firebase Cloud Messaging (FCM) Setup
1. In Firebase Console → Project Settings → **Cloud Messaging**.
2. Enable Cloud Messaging API (V1).
3. Generate private key in **Service accounts** tab or copy Server Key.
4. Set `FCM_SERVER_KEY` in `backend/.env`.

---

## 11. Google Maps Setup
1. Visit the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project called `ResQnet`.
3. Enable **Maps SDK for Android**.
4. Create an API key under **APIs & Services → Credentials**.
5. Restrict the API key:
   - Application restriction: Android apps
   - Package name: `com.resqnet.resqnet`
   - SHA-1 fingerprint (from `keytool -list -v -keystore ~/.android/debug.keystore`)
6. Inject the key during build:
   - Add to `android/gradle.properties`:
     ```properties
     MAPS_API_KEY=YOUR_ACTUAL_GOOGLE_MAPS_KEY
     ```
   - Or pass via CLI:
     ```bash
     flutter run -P MAPS_API_KEY=YOUR_ACTUAL_GOOGLE_MAPS_KEY
     ```

---

## 12. Kotlin Native Integration
ResQnet utilizes Kotlin for mission-critical native Android functionality:
- **`NotificationHelper.kt`**: Creates the `resqnet_emergency_alerts` notification channel configured with `IMPORTANCE_HIGH`, aggressive vibration waveforms `(0, 500, 200, 500, 200, 500)`, custom alert audio attributes, and public lockscreen visibility.
- **`ResQnetNativeBridge.kt`**: Exposes a `MethodChannel` (`com.resqnet/native_bridge`) to Flutter for native hardware haptic feedback, notification channel status verification, and device platform diagnostics.
- **`MainActivity.kt`**: Initializes the native bridge and registers notification channels upon Flutter engine startup.

---

## 13. Environment Variables
Backend `.env` file template (`backend/.env`):
```env
PROJECT_NAME="ResQnet"
ENVIRONMENT="development"
DATABASE_URL="postgresql+asyncpg://resqnet:resqnet_secret@localhost:5432/resqnet_db"
SYNC_DATABASE_URL="postgresql://resqnet:resqnet_secret@localhost:5432/resqnet_db"
JWT_SECRET="YOUR_RANDOM_32_BYTE_HEX_KEY"
JWT_REFRESH_SECRET="YOUR_RANDOM_REFRESH_HEX_KEY"
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=30
DEFAULT_RADIUS_METERS=1000
COMPACT_RADIUS_METERS=500
PRIVACY_MIN_COUNT_THRESHOLD=3
FCM_SERVER_KEY="YOUR_FIREBASE_KEY"
ALLOWED_ORIGINS="*"
```

---

## 14. Running the Backend
1. Ensure your PostgreSQL database is running.
2. In the `backend/` directory:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
3. Test the health check endpoint:
   ```bash
   curl http://localhost:8000/health
   # Returns: {"status":"healthy","service":"ResQnet API","environment":"development"}
   ```
4. Access interactive API documentation:
   - Swagger UI: `http://localhost:8000/docs`
   - ReDoc: `http://localhost:8000/redoc`

---

## 15. Running the Flutter App
1. Connect an Android device with USB debugging or start an Android emulator.
2. From the project root:
   ```bash
   flutter pub get
   flutter run
   ```
3. **Real-World Multi-Device Mode (Default)**:
   - `AppConfig.demoMode` is set to `false` by default.
   - When running on a physical phone, tap the server settings icon (`DNS` icon on the login screen or in Profile) and enter your development PC's Wi-Fi IP address (e.g. `192.168.1.15:8000`).
   - If running on Android Emulator, it automatically routes through `10.0.2.2:8000`.

---

## 16. Real-World Multi-Device Testing (Two Devices / Phones)
To verify real-world emergency notifications between actual devices:
1. **Device 1 (Helper Phone)**:
   - Register or login as Helper (`helper@resqnet.org`).
   - Switch **"Available to Help"** toggle to **ON**.
   - The app automatically registers GPS coordinates with `POST /api/v1/helpers/location` and connects to the live community alert WebSocket channel.
2. **Device 2 (Requester Phone)**:
   - Register or login as Requester (`victim@resqnet.org`).
   - Press and hold the **SOS** button for 2.0 seconds (or select Medical / Fire / Accident).
   - The device captures live GPS coordinates and creates the incident with `POST /api/v1/emergencies`.
3. **Live Proximity Notification & Response Dispatch**:
   - The FastAPI backend calculates spatial distance using PostGIS / spherical math (`dist <= 1000m`).
   - **Device 1 (Helper Phone)** immediately:
     - Triggers loud emergency vibration pattern and native alarm sound.
     - Displays native Android heads-up notification in channel `resqnet_emergency_alerts` ("ResQnet Emergency Alert: SOS - Approximately X m away").
     - Opens `HelperAlertView` with the exact incident location marker on Google Maps.
   - Device 1 helper taps **"I'M COMING"** (`POST /api/v1/emergencies/{id}/respond`).
   - **Device 2 (Requester Phone)** instantly updates in real time via WebSocket:
     - Status updates to **"RESPONDING"**.
     - Display updates to **"1 helper responding"**!
   - Helper taps **"OPEN DIRECTIONS"** to navigate via Google Maps turn-by-turn navigation.
   - When the situation is resolved, Requester taps **"MARK AS SAFE"** or **"CANCEL ALERT"**, notifying all connected helpers and safely ending the emergency.

---

## 17. Automated Tests
Run both test suites:
```bash
# Flutter component, unit & broadcast tests (9 tests)
flutter test

# Backend API & privacy tests (4 tests)
cd backend
python -m pytest tests/ -v
```

### Static Analysis
```bash
flutter analyze
```

---

## 17. Building APK
Generate a release APK for Android testing:
```bash
flutter build apk --release
```
The APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 18. Building AAB (App Bundle)
Generate an Android App Bundle for Google Play Store distribution:
```bash
flutter build appbundle --release
```
The AAB will be located at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 19. Backend Deployment (Docker & Compose)
Launch the entire backend stack with PostgreSQL, PostGIS, and FastAPI in a single command:
```bash
cd backend
docker-compose up --build -d
```
To check container status:
```bash
docker-compose ps
docker-compose logs -f
```

---

## 20. Production Configuration & Security
1. **Never commit `.env` or keystores** to version control.
2. **Rotate JWT secrets**: Generate cryptographically random strings (`openssl rand -hex 32`).
3. **Location Privacy Rules**:
   - ResQnet strictly displays aggregate demographic stats in "Nearby Safety".
   - Exact helper GPS locations and personal identities are never exposed publicly.
   - Low-density areas apply a minimum threshold (k-anonymity) to prevent de-anonymization.
4. **Official Emergency Services**: ResQnet explicitly labels alerts as **community emergency assistance**. An official helpline shortcut (e.g. 112) is built in so users can contact emergency authorities directly.
