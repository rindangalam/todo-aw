# Todoaw v1.0.0

Aplikasi produktivitas offline-first dengan fitur lengkap, dibangun dengan Flutter.

## Fitur Utama

- **Manajemen Tugas** — CRUD lengkap dengan prioritas, deadline, dan label
- **Catatan (Notes)** — Tulis dan kelola catatan harian
- **Kebiasaan (Habits)** — Tracking kebiasaan harian dengan seed data (Minum air 8 gelas, Baca 15 menit)
- **Timer Fokus** — Pomodoro timer untuk produktivitas
- **Home Screen Widget** — Widget Android dengan tema akurat, progress bar, dan stiker ikon
- **Sticker Picker** — Popup stiker dengan teks kustom
- **Notifikasi** — Pengingat lokal untuk tugas dan kebiasaan
- **Tema Terang/Gelap** — Dukungan tema lengkap dengan status bar yang menyesuaikan
- **Edge-to-Edge UI** — Tampilan modern dengan safe area handling

## Tech Stack

- Flutter 3.47.2 / Dart 3.13.2
- Riverpod v2 (State Management)
- SQLite (Offline Database)
- GoRouter (Navigation)
- Kotlin (Android Widget)

## Perubahan v1.0.0

### Bug Fixes
- Perbaikan inisialisasi database dan keandalan CRUD
- Perbaikan visibilitas status bar di tema terang
- Safe area handling untuk konten

### Improvements
- Migrasi Android build ke Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20
- Upgrade dependencies untuk Flutter 3.47 compatibility
- Migrasi flutter_local_notifications ke zonedSchedule API
- Edge-to-edge UI dengan transparan status bar

### Build
- Release APK untuk Android
- compileSdk 36
- NDK menggunakan flutter.ndkVersion

## Install

Download `todoaw.apk` dan install di perangkat Android (min Android 5.0/Lollipop).
