# Todoaw v1.1.0

Aplikasi produktivitas offline-first dengan fitur lengkap, dibangun dengan Flutter.

## Fitur Utama

- **Manajemen Tugas** — CRUD lengkap dengan prioritas, deadline, dan label
- **Catatan (Notes)** — Tulis dan kelola catatan harian
- **Kebiasaan (Habits)** — Tracking kebiasaan harian dengan seed data (Minum air 8 gelas, Baca 15 menit)
- **Timer Fokus** — Pomodoro timer untuk produktivitas
- **Sticker Picker** — Popup stiker dengan teks kustom
- **Notifikasi** — Pengingat lokal dengan WorkManager (persists across app kill & reboot)
- **Tema Terang/Gelap** — Dukungan tema lengkap dengan status bar yang menyesuaikan
- **Edge-to-Edge UI** — Tampilan modern dengan safe area handling

## Tech Stack

- Flutter 3.47.2 / Dart 3.13.2
- Riverpod v2 (State Management)
- SQLite (Offline Database)
- GoRouter (Navigation)
- awesome_notifications (Notification scheduling)

## Perubahan v1.1.0

### New Features
- **OPPO Battery Optimization** — Tombol untuk membuka pengaturan baterai OPPO di Settings

### Improvements
- Migrasi dari flutter_local_notifications ke awesome_notifications
- WorkManager-based scheduling (persists across app kill & reboot)
- Hybrid notification: WorkManager (background) + foreground polling 15 detik (saat app buka)
- Notifikasi tap navigasi ke home screen

### Bug Fixes
- Perbaikan duplicate notification scheduling
- Hapus fitur "Notifikasi Terlewat" yang tidak berfungsi optimal
- Perbaikan reminderMinutes tidak tersimpan ke database

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
