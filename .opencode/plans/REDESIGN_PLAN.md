# Redesign Plan — Todoaw Personal Productivity Suite

> **Status:** Draft — menunggu persetujuan sebelum eksekusi
> **Target:** Aplikasi premium setara TickTick / Todoist / Things 3
> **Bahasa:** Seluruh UI dalam Bahasa Indonesia

---

## Ringkasan

Todoaw akan diubah dari basic todo list menjadi **Personal Productivity Suite** dengan 6 pilar fitur:

| Pilar | Status Saat Ini | Target |
|-------|----------------|--------|
| **Task Management** | ✅ Ada | Redesign UI + animasi premium |
| **Habit Tracker** | ❌ Belum ada | Tracking kebiasaan harian + streak + statistik |
| **Focus Mode** | ❌ Belum ada | Pomodoro timer 25 menit dengan mode fokus |
| **Quick Notes** | ❌ Belum ada | Catatan cepat non-task |
| **Dashboard** | ⚠️ Stats sederhana | Widget lengkap: progress, streak, fokus, produktivitas |
| **Calendar** | ⚠️ Grid bulanan | Agenda view + timeline + color indicator |

---

## Fase Eksekusi

### Fase 0 — Foundation & Design System (Estimasi: 2-3 jam)

Tujuan: Membangun fondasi visual dan arsitektur sebelum menyentuh UI.

#### 0.1 — Design Tokens

Buat file berisi:
- Spacing (8pt grid): 4, 8, 12, 16, 24, 32, 48
- Radius: 12, 16, 24
- Color scheme baru: Primary #5865F2, Secondary #7C3AED, Success #10B981, Warning #F59E0B, Danger #EF4444, Background #F8FAFC, Surface #FFFFFF
- Typography: Plus Jakarta Sans

#### 0.2 — Google Fonts Integration

Tambah dependency google_fonts, set Plus Jakarta Sans sebagai default.

#### 0.3 — Theme Refactor

Pisahkan theme jadi light_theme.dart dan dark_theme.dart, semua warna pakai ColorTokens.

#### 0.4 — Bahasa Indonesia

Buat file l10n/strings.dart — semua UI dalam Bahasa Indonesia.

### Fase 1 — Arsitektur & Database

#### 1.1 — Restruktur Folder

lib/core/design/ — design tokens, theme
lib/core/l10n/ — string Bahasa Indonesia
lib/data/models/ — entity models
lib/data/repositories/ — repository implementations  
lib/domain/services/ — business logic services
lib/providers/ — Riverpod providers
lib/presentation/screens/ — pages
lib/presentation/widgets/ — reusable components

#### 1.2 — Tabel Baru

- habits: uuid, name, description, color, icon, frequency, targetCount, currentStreak, longestStreak, sortOrder, isArchived, createdAt, updatedAt
- habit_logs: uuid, habitId FK, date, isCompleted, note, createdAt
- notes: uuid, title, content, color, isPinned, isArchived, createdAt, updatedAt
- focus_sessions: uuid, taskId, durationMinutes, isCompleted, startedAt, endedAt, createdAt

Modifikasi tasks: tambah reminderMinutes, estimatedMinutes

### Fase 2 — Home Screen Redesign

- Hero Header: greeting + progress ring + weekly progress + streak
- Quick Actions: Tambah Tugas, Tambah Catatan, Mulai Fokus, Tambah Kebiasaan
- Task cards modern dengan animasi

### Fase 3 — Task Management Redesign

- Task form jadi bottom sheet
- Filter chips animasi

### Fase 4 — Calendar Redesign

- Hybrid view: grid compact + agenda timeline
- Color-coded category indicator

### Fase 5 — Dashboard

- Widget: Progress hari ini, Produktivitas 7 hari (bar chart), Streak, Statistik, Ringkasan kebiasaan

### Fase 6 — Habit Tracker

- Habit list + form + detail
- Streak logic

### Fase 7 — Focus Mode

- Pomodoro 25 menit
- Focus mode UI

### Fase 8 — Quick Notes

- Notes list + quick add bottom sheet

### Fase 9 — Settings & Export

- Dark mode, Backup, Restore, Export JSON/CSV/SQLite, Import

### Fase 10 — Polish

- Animasi: hero, staggered list, spring checkbox, swipe
- Haptic feedback
- Performance optimization

---

## Dependencies Baru

| Fase | Package |
|------|---------|
| 0 | google_fonts |
| 5 | fl_chart |
| 9 | share_plus, csv |

---

## Pertanyaan

1. Eksekusi langsung semua fase atau bertahap?
2. Plus Jakarta Sans via Google Fonts atau Inter fallback?
3. Clean Architecture penuh atau tetap struktur lama?
4. Task form full screen atau bottom sheet modal?
5. Dashboard merge dengan Stats screen atau terpisah?
