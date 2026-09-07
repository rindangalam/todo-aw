# Todoaw v1.1.0

Aplikasi produktivitas offline-first dengan fitur lengkap, dibangun dengan Flutter.

## Fitur Utama

- **Manajemen Tugas** — CRUD lengkap dengan prioritas, deadline, dan label
- **Catatan (Notes)** — Tulis dan kelola catatan harian
- **Kebiasaan (Habits)** — Tracking kebiasaan harian dengan seed data (Minum air 8 gelas, Baca 15 menit)
- **Timer Fokus** — Pomodoro timer untuk produktivitas
- **Home Screen Widget** — 5 widget premium dengan tema dark blue
- **Sticker Picker** — Popup stiker dengan teks kustom
- **Notifikasi** — Pengingat lokal dengan WorkManager (persists across app kill)
- **Tema Terang/Gelap** — Dukungan tema lengkap dengan status bar yang menyesuaikan
- **Edge-to-Edge UI** — Tampilan modern dengan safe area handling

## Tech Stack

- Flutter 3.47.2 / Dart 3.13.2
- Riverpod v2 (State Management)
- SQLite (Offline Database)
- GoRouter (Navigation)
- Kotlin (Android Widget)
- awesome_notifications (Notification scheduling)
- flutter_background_service (Foreground service for on-time notifications)

## Perubahan v1.1.0

### New Features
- **Background Notification Service** — Foreground service dengan polling 15 detik untuk notifikasi on-time
- **Home Screen Widget Redesign** — 5 widget baru dengan tema dark blue premium:
  - Today Widget (4x2): Daftar task dengan waktu, progress bar, jumlah selesai
  - Compact Widget (4x1): Logo, progress, next task + waktu
  - Quick Add Widget (4x1): Tombol "+" untuk tambah task
  - Notes Today Widget (4x2): Daftar catatan hari ini
  - Quick Note Widget (4x1): Tombol "+" untuk tambah catatan
- **Notification Settings Toggle** — Aktifkan/nonaktifkan layanan latar belakang
- **OPPO Battery Optimization** — Tombol untuk membuka pengaturan baterai OPPO

### Improvements
- Migrasi dari flutter_local_notifications ke awesome_notifications
- WorkManager-based scheduling (persists across app kill & reboot)
- Hybrid notification approach: WorkManager (background) + foreground polling (instant)
- Notifikasi tap navigasi ke home screen
- Dark blue premium theme untuk semua widget (#0F1729 bg, #3B82F6 accent)

### Bug Fixes
- Perbaikan duplicate notification scheduling
- Perbaikan notification service initialization顺序
- Hapus fitur "Notifikasi Terlewat" yang tidak berfungsi optimal

### Build
- Release APK untuk Android
- compileSdk 36
- NDK menggunakan flutter.ndkVersion

## Install

Download `todoaw.apk` dan install di perangkat Android (min Android 5.0/Lollipop).

## Catatan untuk OPPO/ColorOS

Untuk notifikasi yang optimal:
1. Buka Settings → Notifikasi → Pastikan Notifikasi Aktif
2. Buka Settings → Pengaturan Baterai (OPPO) → Nonaktifkan pengoptimalan baterai
3. Aktifkan Layanan Latar Belakang di settings app
