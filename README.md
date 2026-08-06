# todoaw — Demo Interaktif Statis

Branch `demo` berisi **mockup statis interaktif** dari aplikasi [todoaw](https://github.com/rindangalam/todo-aw) — aplikasi Flutter todo/notes/habit tracker. Semua screen, warna (dari `lib/core/design/tokens.dart`), dan teks (dari `lib/core/l10n/strings.dart`) ditiru dari app asli, tanpa backend dan tanpa build step.

## Cara Menjalankan

Cukup buka `index.html` di browser, atau jalankan server statis:

```bash
python -m http.server 8000
# lalu buka http://localhost:8000
```

Atau via Node:

```bash
npx serve .
```

## Fitur Demo

| Screen | Fitur |
| --- | --- |
| **Beranda** | Hero progress (ring + streak 🔥), 5 quick actions, daftar tugas dengan checkbox animasi, badge prioritas P1–P4, kategori, tag, tanggal (Hari Ini / Besok), FAB tambah tugas, form tugas lengkap (judul, deskripsi, prioritas, deadline, kategori), template tugas |
| **Kalender** | Grid bulan navigable, titik pada tanggal bertugas, klik tanggal → lihat tugas hari itu |
| **Dashboard** | Progress hari ini (ring + bar), chart mingguan, 3 kartu statistik (Aktif / Selesai / Total), kartu streak — semua ter-update otomatis |
| **Catatan** | List note + tambah / edit / hapus |
| **Pengaturan** | Mode gelap, warna aksen, stiker widget, item menu dummy |
| **Bonus** | Timer fokus ala Pomodoro, daftar kebiasaan, toast notifikasi |

Semua data (tugas, catatan, kebiasaan, tema) tersimpan di `localStorage` browser — data tetap ada setelah halaman dimuat ulang. Tombol **Reset Demo** ada di Pengaturan dan panel samping.

## Struktur

```
├── index.html        # Halaman demo (frame HP + panel info)
├── css/style.css     # Tema light/dark + komponen
├── js/demo.js        # Logika (core murni terpisah, bisa dites Node)
└── test/smoke.test.js # Smoke test — node test/smoke.test.js
```

## Smoke Test

```bash
node test/smoke.test.js
```

Menguji logika inti (seed data, add/toggle/delete task, progress, statistik, streak, weekly chart) tanpa browser.

## Catatan

- Demo ini **tidak** menggunakan Flutter — hanya HTML/CSS/JS vanilla.
- Fitur database, notifikasi, widget home screen, export/import hanya ada di app asli (branch `main`).
- Bahasa: Indonesia (sesuai app asli).
