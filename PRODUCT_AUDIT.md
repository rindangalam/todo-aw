# Product Audit — Todoaw

## 1. Competitive Landscape

| Dimensi | TickTick | Todoist | Things 3 | MS To Do | Todoaw |
|---------|----------|---------|----------|----------|--------|
| **Filosofi** | All-in-one Swiss Army knife | Capture cepat, organize kemudian | Opinionated simplicity | Minimalis, ekosistem MS | ❓ Belum jelas |
| **NLP / Smart Parse** | ✅ Baik | ✅⭐ Terbaik | ✅ Dasar | ❌ | ❌ |
| **Calendar View** | ✅⭐ Native + time blocking | ✅ Pro (basic) | ❌ Read-only | ❌ | ✅ Grid + agenda |
| **Habit Tracker** | ✅⭐ Streak, chart | ❌ | ❌ | ❌ | ✅ Streak, log |
| **Pomodoro / Focus** | ✅⭐ Per-task, white noise | ❌ | ❌ | ❌ | ✅ Timer ring |
| **Kanban / Board** | ✅ | ✅ (recent) | ❌ | ❌ | ❌ |
| **Notes** | ✅ Markdown | ✅ Rich | ✅ Per-task | ❌ | ✅ Color-coded |
| **Collaboration** | ✅ Dasar | ✅⭐ 60+ integrasi | ❌ | ✅ Terbatas | ❌ |
| **Cross-platform** | ✅ Semua | ✅⭐ Semua | ❌ Apple only | ✅ Windows native | 🔄 Flutter |
| **Harga** | $36/thn | $48-72/thn | $80 sekali | Gratis | **Gratis FOSS** |
| **Bahasa Indonesia** | ❌ | ❌ | ❌ | ❌ | **✅ Full 🇮🇩** |
| **Gamifikasi** | ❌ | ✅ Karma | ❌ | ❌ | ✅ Streak |
| **Desain** | ⭐⭐⭐ Cukup | ⭐⭐⭐⭐ Baik | ⭐⭐⭐⭐⭐ Ikonik | ⭐⭐⭐⭐ Bersih | ⭐⭐⭐ |

---

## 2. Product Identity

### Siapa Todoaw?

Todoaw BUKAN:
- Bukan TickTick versi kedua (tidak mau all-in-one yang ramai)
- Bukan Things 3 untuk orang Indonesia (tidak copot desain Apple)
- Bukan Todoist gratisan (tidak adopsi NLP/integrasi mereka)

### 3 Pilar Identitas Todoaw:

**1. 🇮🇩 Lokal First**
Bukan cuma translate. Budaya kerja Indonesia: gotong royong, jam kerja fleksibel, konsep "besok" yang longgar. Todoaw mengerti Indonesia. Greeting "Selamat Pagi", hari/bulan Indonesia, frase "insyaAllah" untuk recurring.

**2. 🧘 Calm Productivity**
Anti-FOMO, anti-stress. Tidak ada notifikasi agresif, gamifikasi minimal. Todoaw membantu tanpa bikin cemas. Ini kontras langsung dengan TickTick yang ramai dan Todoist yang kompetitif.

**3. 🔧 Modular & FOSS**
Open source, gratis, no subscription. User pilih fitur yang dipakai. Privasi total — data di SQLite lokal.

### Positioning Statement:

> *"Untuk profesional muda dan mahasiswa Indonesia yang ingin produktif tanpa stress, Todoaw adalah aplikasi produktivitas yang terasa alami dalam bahasa Indonesia — bukan seperti aplikasi luar yang dingin dan penuh tekanan."*

### Tagline:
**"Atur hidupmu, tanpa ribet."**

---

## 3. Product Vision

> **Todoaw adalah Calm Productivity companion untuk Asia Tenggara — membantu kamu mengatur hidup dengan cara sendiri, dalam bahasamu sendiri, tanpa kebisingan.**

### Misi:
1. Menjadi task manager #1 di Indonesia
2. Contoh produk open source yang bersaing dengan produk komersial
3. Membangun budaya calm productivity di era notifikasi berlebihan

---

## 4. Feature Priority Matriks

| Fitur | Effort | Impact | Unik? | Prioritas | Fase |
|-------|--------|--------|-------|-----------|------|
| NLP / Smart Date Parse | 🟡 Medium | 🔴 High | ❌ | **P0 Wajib** | v2.0 |
| Search bar di home | 🟢 Low | 🔴 High | ❌ | **P0 Wajib** | v2.0 |
| Widget home screen | 🟡 Medium | 🔴 High | ❌ | **P0 Wajib** | v2.0 |
| Notifikasi timer focus | 🟢 Low | 🟡 Medium | ❌ | **P0 Wajib** | v2.0 |
| Export/backup data | 🟡 Medium | 🔴 High | ❌ | **P0 Wajib** | v2.0 |
| Swipe feedback TaskCard | 🟢 Low | 🟡 Medium | ❌ | **P0 Wajib** | v2.0 |
| Onboarding flow | 🟡 Medium | 🟡 Medium | ❌ | P1 | v2.0 |
| Calendar drag time block | 🔴 High | 🟡 Medium | ❌ | P1 | v2.0 |
| Kanban board view | 🔴 High | 🟡 Medium | ❌ | P1 | v2.5 |
| **Mood & Energy tracking** | 🟡 Medium | 🟢 High | ✅ **WOW** | **P1** | v2.5 |
| **"Mode Santai" toggle** | 🟢 Low | 🟢 High | ✅ **WOW** | **P1** | v2.0 |
| **Voice quick capture** | 🔴 High | 🟢 High | ✅ **WOW** | P2 | v3.0 |
| **Gotong Royong sharing** | 🔴 High | 🟢 High | ✅ **WOW** | P2 | v3.0 |
| Kalender eksternal sync | 🔴 High | 🟡 Medium | ❌ | P2 | v3.0 |
| AI task breakdown | 🔴 High | 🟡 Medium | ❌ | P3 | v3.5 |
| iOS / macOS / Windows | 🔴 High | 🔴 High | ❌ | P3 | v3.0+ |

---

## 5. WOW Features (Differentiators)

Fitur yang membuat Todoaw berbeda — bukan copian dari kompetitor:

### 🔥 WOW #1: "Gimana Mood Kamu Hari Ini?"
Daily mood/energy check-in (emoji slider). Todoaw rekam mood + produktivitas, lalu kasih insight: *"Kamu paling produktif pas mood 'semangat' di hari Selasa"*. TickTick/Todoist tidak punya ini.

### 🔥 WOW #2: "Mode Santai"
Satu toggle yang sembunyikan:
- Deadline (ganti jadi "minggu ini")
- Streak counter
- Statistik
- Notifikasi push

Yang kelihatan cuma: **"Apa yang perlu kamu kerjakan hari ini."** Cocok untuk user yang burnout.

### 🔥 WOW #3: "Beres Dulu" Voice Capture
Dari home screen, tap mic → rekam "beli beras sama sabun mandi besok" → auto NLP → jadi task + date. Beda dari voice competitor karena dioptimalkan untuk bahasa Indonesia sehari-hari.

### 🔥 WOW #4: Gotong Royong Sharing
Share task list ke keluarga/teman tanpa akun. Cukup generate QR code atau link. Scan → lihat list. Simple, private, no signup. Cocok untuk: list belanja keluarga, tugas kelompok mahasiswa.

### 🔥 WOW #5: "Besok, InsyaAllah"
Recurring task dengan frase Indonesia: "Setiap hari kerja," "Setiap akhir bulan," "Seminggu sekali," "Besok insyaAllah" — tanggal otomatis menyesuaikan. Bukan cuma translate "every weekday."

---

## 6. Roadmap v2.0 — "Make it Complete"
*Target: 2-3 bulan*

### P0 — Wajib:
- [ ] NLP / Smart Date Parsing (ketik "besok jam 3" → parse otomatis)
- [ ] Search bar di home screen (bukan route terpisah)
- [ ] Swipe visual feedback di TaskCard
- [ ] Notifikasi + vibration saat focus timer selesai
- [ ] Export/backup data (SQLite dump + JSON)
- [ ] Android home screen widget
- [ ] "Mode Santai" toggle

### P1 — Penting:
- [ ] Onboarding flow (3 screen: "Atur hidupmu, tanpa ribet")
- [ ] Calendar month transition animation (slide/fade)
- [ ] HapticFeedback di semua toggle (done ✅)
- [ ] FilterSheet selected state visual improvement

### P2 — Setelah itu:
- [ ] Mood & Energy tracking (foundation: simpan mood per hari di DB)

---

## 7. Roadmap v3.0 — "Uniquely Todoaw"
*Target: 3-6 bulan*

### WOW Features:
- [ ] **Mood & Energy dashboard** — insight mood vs produktivitas
- [ ] **Voice quick capture** — Record → transcribe → task
- [ ] **Gotong Royong sharing** — QR code / link sharing
- [ ] **"Besok, InsyaAllah"** — Recurring dengan frase Indonesia

### Platform:
- [ ] Kalender eksternal sync (Google Calendar read-only)
- [ ] Kanban board view
- [ ] iOS / macOS via Flutter
- [ ] Windows app via Flutter

### Improvement:
- [ ] Cross-device sync via file export (manual)
- [ ] Dark mode refinement
- [ ] Animasi dan micro-interaction polish

---

## 8. Fitur yang Wajib Dibuat (P0)

1. **NLP / Smart Date Parsing** — Input teks "besok jam 3" auto-set date/time
2. **Search bar di home screen** — Search tanpa navigasi ke route terpisah
3. **Swipe visual feedback TaskCard** — Card shrink/offset saat drag
4. **Focus timer notification** — Sound + vibration saat timer selesai
5. **Export/backup data** — JSON + SQLite export
6. **Android home screen widget** — Tasks hari ini + progress
7. **"Mode Santai" toggle** — Anti-stress mode

---

## 9. Fitur yang Sebaiknya Dihapus / Disederhanakan

1. **Subtask system (parentId)** — Implementasi saat ini 2 level, nyelip di form. Usage rendah. **Ganti dengan checklist di description field.**
2. **RecurrenceRule kompleks** — `interval`, `byDay`, `byMonthDay` over-engineering. Cukup "setiap hari / minggu / bulan / hari kerja".
3. **DeletedAt soft delete** — Ganti dengan purge langsung. Atau tabel trash terpisah tanpa `deletedAt` column.

---

## 10. Fitur yang Perlu Ditunda

1. Collaboration / sharing tim → **v3.0+** (butuh backend)
2. AI task breakdown → **v3.5** (butuh NLP dulu)
3. Integrasi kalender eksternal → **v3.0** (butuh OAuth)
4. Cross-platform iOS/Windows → **v3.0+** (flutter sudah siap, tinggal build)
5. Gamifikasi / leaderboard → **TIDAK JADI** (bertentangan dengan "calm productivity")

---

## 11. User Journey Improvements

### Current Pain Points:

| Pain Point | Solusi | Priority |
|------------|--------|----------|
| User baru buka app → layar kosong → bingung | Onboarding flow + empty state lebih baik | P1 |
| Tambah task perlu 5 tap | NLP + quick capture | **P0** |
| Cari task harus ke `/search` route | Search bar di home | **P0** |
| Timer focus selesai diam saja | Notifikasi + vibration | **P0** |
| Data hilang kalau hapus app | Export/backup | **P0** |
| Stress lihat deadline numpuk | "Mode Santai" | **P1** |
| Tidak bisa lihat progress hari ini dari luar | Widget home screen | **P0** |

### Ideal User Flow (v2.0):

1. Buka app → lihat splash (brand)
2. Onboarding (first-time) → "Atur hidupmu, tanpa ribet"
3. Home: **Search bar** di atas → ketik "beli beras besok" → auto-create
4. Quick Actions row → tambah task, catatan, fokus, habit
5. Task list → swipe dengan **visual feedback** → complete/delete
6. Timer fokus selesai → **vibrasi + notifikasi**
7. Stress? → toggle **"Mode Santai"** → semua deadline hilang
8. Mau ganti HP? → **Export data** → JSON file

---

## 12. Summary: Todoaw vs Kompetitor

| Kita Tidak Akan | Kita Akan |
|----------------|-----------|
| Meniru NLP sempurna Todoist | NLP sederhana + bahasa Indonesia |
| Meniru TickTick all-in-one clutter | Fokus, bersih, modular |
| Meniru harga subscription | Gratis FOSS selamanya |
| Meniru Things 3 Apple-only | Cross-platform (mulai Android) |
| Meniru MS To Do minimal berlebihan | Fungsional + tetap simpel |
| Push notifikasi agresif | Kalau lagi "Mode Santai" — semua senyap |
| Gamifikasi kompetitif | Streak sebagai bonus, bukan tekanan |
