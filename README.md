# Todoaw — Aplikasi Todo & Produktivitas

**Todoaw** adalah aplikasi *offline-first* untuk membantu Anda mengatur tugas harian, mencatat ide, melacak kebiasaan, dan tetap fokus — semuanya tersimpan secara lokal di perangkat Anda tanpa perlu koneksi internet.

---

## Fitur Lengkap

### 📋 Manajemen Tugas
- **CRUD tugas** — Buat, edit, selesaikan, hapus tugas dengan mudah
- **Prioritas** — P1 (Penting), P2 (Sedang), P3 (Biasa), P4 (Ringan)
- **Kategori & Tag** — Kelompokkan tugas dengan kategori berwarna dan tag/label
- **Subtask** — Sub-tugas bertingkat (maks 2 level)
- **Tugas Berulang** — Harian, weekday, mingguan, bulanan, tahunan dengan interval custom
- **Template** — Simpan tugas sebagai template untuk digunakan kembali
- **Batch Operations** — Pilih banyak tugas sekaligus untuk selesaikan, arsipkan, atau hapus (long-press)
- **Tenggat Waktu & Pengingat** — Atur deadline dan pengingat notifikasi (5/15/30/60 menit sebelumnya)
- **Arsip & Tong Sampah** — Arsipkan tugas yang selesai; tugas yang dihapus masuk tong sampah dengan auto-purge 30 hari

### 📝 Catatan
- **CRUD catatan** dengan judul dan konten
- **Pilihan warna** (6 warna) untuk membedakan catatan
- **Pin catatan** — Catatan yang dipin tampil di atas grid
- **Pencarian** inline di layar Catatan

### 🔥 Kebiasaan (Habit Tracker)
- **CRUD kebiasaan** dengan target harian/mingguan/bulanan
- **Log harian** — Centang kebiasaan setiap hari
- **Streak** — Lihat konsistensi Anda dengan hitungan streak

### ⏱️ Fokus Timer (Pomodoro)
- **Timer** 15, 25, 30, 50 menit
- **Animasi ring** yang menunjukkan progress waktu
- **Riwayat sesi** — Total menit fokus hari ini
- **Haptic feedback & notifikasi** saat sesi selesai

### 📊 Dashboard & Statistik
- **Progress ring** — Persentase penyelesaian hari ini
- **Bar chart mingguan** — Tugas selesai per hari (Senin-Minggu)
- **Stat cards** — Tugas Aktif, Selesai, Total
- **Streak** — Api 🔥 yang menunjukkan produktivitas konsisten

### 📅 Kalender
- **Tampilan bulan** dengan navigasi prev/next
- **Titik warna** pada tanggal yang memiliki tugas
- **Agenda harian** — Daftar tugas untuk tanggal yang dipilih
- **Tombol "Hari Ini"** untuk kembali ke tanggal sekarang

### 🔍 Pencarian & Filter
- **Pencarian real-time** — Cari tugas & catatan saat mengetik
- **Filter sheet** — Saring berdasarkan prioritas, kategori, tag, status selesai/diarsipkan

### 🎨 Tema & Kustomisasi
- **Mode tema** — Sistem, Terang, Gelap
- **Pilih warna aksen** — Bebas pilih warna utama aplikasi:
  - Palette (91 warna)
  - Material (54 warna)
  - Custom (HSV slider)
- **Tersimpan otomatis** — Tema tidak berubah setelah aplikasi ditutup

### 🚀 Onboarding & Tour
- **Intro slides** (3 halaman) saat pertama kali buka aplikasi
- **Coachmark tour** — Panduan interaktif di layar Beranda & Catatan
- **Reset tour** — Nyalakan lagi dari Pengaturan

### 💾 Data Export/Import
- **Export JSON** — Backup lengkap semua data
- **Export CSV** — Data tugas dalam format spreadsheet
- **Export SQLite** — File database mentah
- **Import JSON** — Restore backup
- **Contoh data (Seed)** — Muat data sampel untuk mencoba fitur

### 🔔 Notifikasi & Widget
- **Notifikasi pengingat tugas** sesuai deadline yang diatur
- **Notifikasi selesai sesi fokus**
- **Android Home Widget** — Lihat ringkasan tugas di layar utama (Compact & List widget)

---

## Cara Install APK

1. **Download file** `todoaw.apk` dari repository ini
2. Buka file tersebut di perangkat Android Anda
3. Jika muncul peringatan *"Install from unknown sources"*, aktifkan izin instalasi dari sumber tidak dikenal (Pengaturan → Keamanan)
4. Klik **Install** dan tunggu hingga selesai
5. Buka aplikasi **Todoaw** dari layar utama

> **Catatan:** Aplikasi ini sepenuhnya offline. Semua data tersimpan di perangkat Anda. Tidak perlu akun atau koneksi internet.

### Persyaratan Sistem
- Android 5.0 (API 21) atau lebih baru
- Ruang penyimpanan ~50 MB

---

## Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| **Flutter 3.x** (Dart) | Framework UI |
| **Riverpod v2** | State management |
| **sqflite** (SQLite) | Database lokal |
| **go_router** | Routing & navigasi |
| **flutter_local_notifications** | Notifikasi lokal |
| **tutorial_coach_mark** | Tour interaktif |
| **home_widget** | Android home widget |
| **shared_preferences** | Penyimpanan preferensi |
| **intl** | Format tanggal & angka |
| **uuid** | ID unik |

---

## Development

```bash
# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run

# Build APK release
flutter build apk --release

# Build APK split per architecture
flutter build apk --release --split-per-abi
```

Dibuat dengan ❤️ menggunakan Flutter.
