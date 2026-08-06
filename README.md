# DSMES Mobile Application

Aplikasi Mobile Client **DSMES Aceh** untuk Pasien Diabetes Melitus.

## 🚀 Tech Stack & Package Utama

- **Framework**: **Flutter** (Dart SDK `^3.7.0`)
- **State Management**: **Flutter Riverpod 2.6.1** & `riverpod_generator`
- **Routing**: **GoRouter 14.6.3**
- **Immutable Models**: **Freezed 3.0.0** & `json_annotation`
- **HTTP Client**: **Dio 5.7.0** (Interceptors & Auth Tokens)
- **Local Storage**: `flutter_secure_storage` & `shared_preferences`
- **Biometric Auth**: `local_auth` (Fingerprint & FaceID)
- **Notifications**: `flutter_local_notifications` 18.0.1 & `timezone`
- **UI & Utilities**: Google Fonts, Flutter SVG, Shimmer, Youtube Player Flutter, Flutter Widget from HTML

## 🏗️ Struktur Proyek

```text
lib/
├── app/          # Initial routes & App configuration
├── core/         # Network client, theme, constants, storage, security
└── features/     # Feature modules
    ├── auth/          # Login, Register, Biometric, OTP
    ├── home/          # Dashboard Pasien & Summary
    ├── record/        # Pencatatan Gula Darah, Nutrisi & Rutinitas
    ├── education/     # Artikel & Video Edukasi DSMES
    ├── questionnaire/ # Quiz & Assessment Mandiri
    ├── notifications/ # Local Reminder System
    ├── ai_chat/       # AI Health Assistant Chat
    └── settings/      # Profil & Pengaturan Akun Pasien
```

## 🛠️ Menjalankan Mobile App

```bash
# Get dependencies
flutter pub get

# Generate freezed & riverpod code
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```
