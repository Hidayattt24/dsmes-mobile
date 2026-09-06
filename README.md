# DSMES Aceh Mobile Application

Aplikasi mobile untuk pasien Diabetes Melitus dalam menjalankan manajemen mandiri, mengikuti edukasi DSMES, mencatat kondisi kesehatan, dan menerima pengingat rutinitas.

## Tujuan Sistem

Mobile app menjadi client utama pasien. Pasien dapat mengisi profil kesehatan, mencatat gula darah dan pola makan, memantau aktivitas, mengikuti assessment, membaca edukasi, serta berkomunikasi dengan AI assistant. Semua data utama disimpan melalui backend DSMES.

## Fitur Utama

- Authentication: login, register, reset password, refresh token, logout, dan session restore.
- Biometric login menggunakan fingerprint atau Face ID jika tersedia.
- Onboarding kesehatan dan sosiodemografi.
- Dashboard pasien dengan ringkasan kesehatan dan progress.
- Catatan gula darah beserta waktu pengukuran dan hasil klasifikasi backend.
- Catatan makanan, porsi, asupan kalori, dan riwayat nutrisi.
- Catatan aktivitas fisik, obat, dan rutinitas.
- Reminder serta notifikasi lokal berbasis timezone.
- Edukasi artikel/video DSMES dan progress belajar.
- Pre-test, questionnaire, quiz, survey, dan hasil assessment.
- AI diabetes assistant chat.
- Profil pasien, foto profil, keamanan, bantuan, dan pengaturan akun.
- Responsive UI untuk compact Android, standard Android, dan ukuran layar yang lebih besar.

## Teknologi

- Flutter dan Dart SDK `^3.7.0`
- Riverpod `2.6.1`
- GoRouter `14.6.3`
- Dio `5.7.0`
- Freezed dan JSON Serializable
- Flutter Secure Storage dan Shared Preferences
- Local Auth
- Flutter Local Notifications dan timezone
- Image Picker
- Google Fonts, SVG, Shimmer, HTML widget, dan YouTube player

## Struktur Proyek

```text
lib/app/             Konfigurasi aplikasi dan shell navigasi
lib/core/            Theme, network client, constants, storage, dan utilities
lib/data/            Repository dan akses data
lib/features/auth/   Login, register, biometric, dan reset password
lib/features/home/   Dashboard, reminder, dan catatan ringkasan
lib/features/record/ Catatan gula darah, makanan, aktivitas, dan obat
lib/features/education/ Artikel dan video edukasi
lib/features/questionnaire/ Pre-test, quiz, survey, dan assessment
lib/features/notifications/ Notifikasi pasien
lib/features/ai_chat/ AI health assistant
lib/features/settings/ Profil dan pengaturan akun
assets/              Gambar dan icon aplikasi
tool/                Script environment dan build APK
```

## Prasyarat

- Flutter SDK
- Android SDK dan emulator atau perangkat Android
- Backend DSMES aktif

## Environment API

API di-inject saat compile menggunakan `BASE_URL`.

```text
BASE_URL    URL base REST API DSMES
```

Nilai yang umum digunakan:

```text
Windows/web:       http://localhost:8080/api/v1
Android emulator:  http://10.0.2.2:8080/api/v1
Staging:            http://72.62.198.217:8080/api/v1
Production:         gunakan URL HTTPS production
```

Android emulator tidak dapat menggunakan `localhost` untuk mengakses komputer host. Script local otomatis mengubah `localhost` menjadi `10.0.2.2` untuk emulator.

## Setup dan Code Generation

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Menjalankan Aplikasi

Backend local melalui Android emulator:

```powershell
.\tool\run-local.ps1
```

Device tertentu:

```powershell
.\tool\run-local.ps1 -DeviceId <device-id>
```

Physical device melalui IP LAN komputer:

```powershell
.\tool\run-local.ps1 -DeviceId <device-id> `
    -ApiBaseUrl http://192.168.1.10:8080/api/v1
```

Staging:

```powershell
.\tool\run-staging.ps1
```

## Build APK

Debug APK local:

```powershell
flutter build apk --debug `
    --dart-define=BASE_URL=http://10.0.2.2:8080/api/v1
```

Release APK:

```powershell
.\tool\build-production.ps1
```

Output APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

HTTP IP hanya cocok untuk testing sementara. Untuk distribusi publik gunakan HTTPS dan signing key release yang aman.

## Arsitektur Client

```text
Screen/Widget
    -> Riverpod Provider/Notifier
    -> Repository
    -> Dio Client + Auth Interceptor
    -> DSMES REST API
```

Token autentikasi disimpan menggunakan secure storage. Jangan memasukkan JWT, password, atau API key ke source code.

## Validasi

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Uji khusus sebelum distribusi:

- Login dan refresh session.
- Backend local, staging, dan production.
- Android emulator dan physical device.
- Keyboard terbuka pada form/dialog/sheet.
- Font scale besar dan layar compact.
