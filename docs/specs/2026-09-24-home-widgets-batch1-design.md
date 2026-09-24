# Design Spec — Home Screen Widgets Batch 1 (Todoaw)

| | |
|---|---|
| **Tanggal** | 2026-09-24 |
| **Status** | Approved (desain 5 bagian) |
| **Scope** | Batch 1: 7 widget Android, full interaktif, dari nol |
| **Out of scope** | Batch 2 widget sisa, iOS WidgetKit, config screen per-user |

---

## 1. Ringkasan keputusan

| Topik | Keputusan |
|---|---|
| Mulai dari | **Dari nol** — kode widget lama di working tree dihapus; hanya jadi referensi pola. `home_widget` & `workmanager` **harus di-add ulang** ke `pubspec.yaml` |
| Pendekatan teknis | **A**: `home_widget` + RemoteViews Kotlin (bukan Glance, bukan native-SQLite) |
| Batch | **Batch 1 = 7 widget core** dulu → test manual di device → Batch 2 |
| Interaktivitas | **Full**: centang dari widget, Quick Add/Note via overlay Activity, deep link |
| Platform | **Android dulu**; iOS di batch/later |
| Theme | **Full**: light/dark + accent color ikut app (bukan fixed dark only) |
| Refresh | **On data change + app lifecycle + WorkManager periodik 30 menit** (bukan foreground service) |
| Acceptance | **Manual checklist di device pribadi user** |

### Widget Batch 1 (7)

| # | Widget | Grid | Fungsi |
|---|---|---|---|
| 1 | Today | 4×2 | List ≤5 tugas hari ini + progress + toggle |
| 2 | Dashboard | 4×4 | Greeting, stats, next task, quick actions |
| 3 | Compact | 4×1 | Progress + next task |
| 4 | Priority | 4×2 | Tugas P1/P2 + badge High/Medium + toggle |
| 5 | Quick Add | 4×1 | Overlay input tugas baru |
| 6 | Notes Today | 4×2 | ≤4 note hari ini / terbaru |
| 7 | Quick Note | 4×1 | Overlay input catatan cepat |

Batch 2 (belum dirancang detail): Notes List 4×4, Mini 1×1, Mini Note 1×1, Note Preview 4×2, sisanya dari referensi 12.

---

## 2. Arsitektur

### 2.1 Write path (Dart → home screen)

```
TaskRepository / NoteRepository (SQLite)     ← satu-satunya source of truth
        ↓
WidgetBridge.updateAll() (Dart)
  - resolve theme (mode + accent) → hex palet
  - query repo → kompres payload per kunci
  - HomeWidget.saveWidgetData(...)
        ↓
SharedPreferences (via home_widget)
        ↓
7× AppWidgetProvider (Kotlin) → RemoteViews → AppWidgetManager.updateAppWidget
```

### 2.2 Refresh triggers

| # | Trigger | Mekanisme |
|---|---|---|
| A | On data change | Hook setelah CRUD app / setelah toggle dari widget → `WidgetBridge.updateAll()` |
| B | App lifecycle | `AppLifecycleState.resumed` + sekali di `main()` setelah DB init |
| C | WorkManager periodik | `home_widget` + `workmanager`, interval **30 menit**, work name `todoaw.widget.refresh`, constraint network NOT_REQUIRED; background Dart isolate → recompute SQLite → push → update 7 provider |

**Dilarang:** `flutter_background_service` / foreground service (riwayat crash Android 14, commit 65eacd5).

### 2.3 Action path (home screen → app / DB)

| Aksi | Mekanisme | Hasil |
|---|---|---|
| Toggle task ✓ | Broadcast → `WidgetActionReceiver` → Dart `home_widget` receiver | `TaskRepository` toggle → `updateAll()`; app tidak terbuka |
| Quick Add / Quick Note | `QuickInputActivity` (transparan di atas launcher) | MethodChannel `todoaw/widget` → `saveQuick` → SQLite → finish → refresh |
| Tap row task/note | PendingIntent → `MainActivity` extras | go_router: `open_task` → form, `open_note` → edit note |
| Logo / header / View All / ring | PendingIntent → `MainActivity` | `open_home` \| `open_notes` \| `open_dashboard` \| `open_tasks_priority` |

### 2.4 Keputusan struktur Kotlin

- Semua kode widget di package `com.todoaw.todoaw.widget/`.
- **7 provider terpisah** + `BaseWidgetProvider` bersama (error handling, helper update).
- Layout XML per widget; **warna di-push dari Dart** (bukan hardcode), struktur di XML.
- `schemaVersion` di payload; Kotlin dengan versi tidak dikenal → fallback empty state (jangan crash).

---

## 3. Spesifikasi per widget

### 3.1 Today (4×2)

- **Header:** logo `todoaw`, `dateLabel` (intl, lokal).
- **Body:** judul “Today” + subtitle motivasi ringan (ID, tetap, bukan di-push); progress ring/completed dari payload.
- **List:** ≤5 item `{uuid, title, time, done}` — urut dueDate hari ini; checkbox + jam.
- **Empty:** “Belum ada tugas hari ini 🌿” (calm, bukan error).
- **Interaksi:** checkbox → toggle; row → `open_task`; logo → `open_home`.

### 3.2 Dashboard (4×4)

- **Header:** `greeting` (Selamat Pagi/Siang/Sore/Malam — dihitung di Dart, ID) + progress.
- **Stats:** 3 kartu — `tasksTodayCount` = tugas hari ini **belum selesai**; `notesTodayCount` = note hari ini; `totalTodayCount` = **semua** tugas hari ini (done + undone).
- **Next task block:** title + time atau “—”.
- **Actions:** Add Task → overlay `mode=task`; Add Note → overlay `mode=note`; **View All → `open_home`** (terkunci).
- **Empty:** greeting + stats 0 + next “—”; tombol tetap hidup.

### 3.3 Compact (4×1)

- Progress mini + `nextTaskTitle` + `nextTaskTime` + chevron.
- **Empty:** ring 0% + “Tidak ada tugas berikutnya”.
- **Interaksi:** body → `open_task` (jika ada uuid) else `open_home`.

### 3.4 Priority (4×2)

- Header “Prioritas” + jumlah.
- List ≤5: `{uuid, title, time, level}` — hanya **P1 → High (#EF4444)**, **P2 → Medium (#F59E0B)**; P3/P4 tidak ditampilkan.
- Link “Lihat semua →” → `open_tasks_priority`.
- **Empty:** “Tidak ada prioritas tinggi” + link ke tasks.
- **Interaksi:** checkbox → toggle; row → open_task.

### 3.5 Quick Add (4×1) & Quick Note (4×1)

- Pure action: field placeholder + tombol +.
- Tap → `QuickInputActivity` extra `mode=task|note`.
- Setelah simpan sukses → activity finish → bridge refresh (Today / Notes Today ikut).

### 3.6 Notes Today (4×2)

- ≤4 note `{uuid, title, preview, time, pinned}`.
- Definisi: `!isArchived &&` (createdAt atau updatedAt **hari ini**); sort **pin dulu**, lalu `updatedAt` desc.
- **Empty:** “Belum ada catatan hari ini”.
- **Interaksi:** row → `open_note`; header → `open_notes`.

---

## 4. Kontrak data

### 4.1 Kunci SharedPreferences

Semua nilai string (kecuali JSON ditandai):

| Kunci | Format | Pemakai |
|---|---|---|
| `schemaVersion` | int string (=1) | semua |
| `progress` | 0–100 | Today, Dashboard, Compact |
| `completedCount`, `totalCount` | int string | Today, Dashboard, Compact |
| `todayTaskList` | JSON `[{uuid,title,time,done}]` max 5 | Today |
| `priorityTaskList` | JSON `[{uuid,title,time,level}]` max 5 | Priority |
| `nextTaskTitle`, `nextTaskTime`, `nextTaskUuid` | string (boleh kosong) | Compact, Dashboard |
| `notesTodayList` | JSON `[{uuid,title,preview,time,pinned}]` max 4 | Notes Today |
| `notesTodayCount`, `tasksTodayCount`, `totalTodayCount` | int string | Dashboard |
| `greeting` | string | Dashboard |
| `dateLabel` | string | Today, Notes Today |
| `hasTodayTasks`, `hasPriorityTasks`, `hasNotesToday` | `"0"`\|`"1"` | empty-state cepat |
| `themeMode` | `light`\|`dark` (resolved) | semua |
| `bgColor`, `cardBgColor`, `accentColor`, `textColor`, `mutedColor`, `dangerColor`, `warnColor`, `successColor` | hex ARGB 8 digit | semua |

### 4.2 Aturan domain (konsisten app)

- **Tugas hari ini (Today + progress):** `dueDate` pada hari lokal berjalan **saja** (bukan termasuk overdue). Overdue P1/P2 tetap muncul di **Priority** jika masih pending.
- **Next task:** pending dengan dueDate terkecil ≥ sekarang; jika tidak ada → pending tanpa dueDate, terbaru diurut created.
- **Priority:** `!isCompleted && priority ∈ {P1,P2}`; sort P1 dulu, lalu dueDate.
- **Progress:** `completed / total` pada cakupan “hari ini” (aturan di atas); total = jumlah task dalam cakupan itu (done + undone). **Jika total = 0** → `progress = 0`, tampilkan empty state (bukan div/0).
- Semua string widget: **Bahasa Indonesia**.

### 4.3 MethodChannel `todoaw/widget`

```
// QuickInputActivity → Dart
saveQuick({ mode: "task"|"note", title: String, time?: "HH:mm" })
  → { ok: true }
  → { ok: false, error: string }   // tampilkan inline; JANGAN finish

// title: trim, wajib non-empty
// time (task only): dueDate = hari ini + jam; opsional
```

Receiver broadcast (via home_widget): `toggle_task` + `uuid`.

### 4.4 Palet theme

**Direction:** “Dark blue premium” Todoaw (bukan Material You default).

| Token | Dark | Light |
|---|---|---|
| bg | `#0F1729` | `#F8FAFC` |
| card | `#1A2540` | `#FFFFFF` |
| text | `#FFFFFF` | `#0F172A` |
| muted | `#94A3B8` | `#64748B` |
| border | `#1E293B` | `#E2E8F0` |
| accent | user (default `#3B82F6`) | user |

Semantic (tidak ikut accent): High `#EF4444`, Medium `#F59E0B`.

- Radius: card 14–16dp, chip pill, tombol ~10dp (selaras PRODUCT_BIBLE).
- Type: title 14–16sp bold, body 12–13sp, caption 10–11sp muted.
- `themeMode=system` → resolve brightness saat update (lifecycle / WorkManager); ganti quick-settings tanpa buka app → sinkron di interval berikutnya.

---

## 5. State coverage

| Widget | Empty | Stale / loading | Error / corrupt payload |
|---|---|---|---|
| Today | Pesan lembut; ring 0 atau disembunyikan; header tetap | Tampilkan prefs terakhir | JSON fail → list kosong → empty; log; no crash |
| Dashboard | Greeting + 0/0/0 + next “—”; tombol hidup | Prefs terakhir | Default per field |
| Compact | Ring 0 + “Tidak ada tugas berikutnya” | Prefs terakhir | Sembunyikan next; ring tetap |
| Priority | “Tidak ada prioritas tinggi” + link | Prefs terakhir | → empty |
| Quick Add/Note | Tetap tampil | n/a | Inline error di overlay; activity tetap terbuka |
| Notes Today | “Belum ada catatan hari ini” | Prefs terakhir | → empty |

**Prinsip:** widget tidak pernah menampilkan error merah memalukan; `onUpdate` selalu try/catch + fallback default.

---

## 6. Struktur file

```
lib/services/widget_bridge.dart              # NEW — payload + updateAll + theme resolve
lib/services/widget_actions.dart             # NEW — action constants
lib/services/widget_quick_input_channel.dart # NEW — saveQuick handler
lib/main.dart                                # EDIT — Workmanager init, lifecycle hook
lib/presentation/router.dart                 # EDIT — handle action extras
lib/providers/** (observer)                  # EDIT — updateAll setelah CRUD

android/.../kotlin/com/todoaw/todoaw/widget/
  WidgetTheme.kt, WidgetData.kt, BaseWidgetProvider.kt
  TodayWidget.kt, DashboardWidget.kt, CompactWidget.kt, PriorityWidget.kt
  QuickAddWidget.kt, NotesTodayWidget.kt, QuickNoteWidget.kt
  QuickInputActivity.kt, WidgetActionReceiver.kt
android/.../MainActivity.kt                  # EDIT — parse extras → Flutter
android/.../res/layout/widget_*.xml          # NEW ×7 + widget_quick_input.xml
android/.../res/xml/widget_*_info.xml        # NEW ×7 (updatePeriodMillis=0)
pubspec.yaml                                 # EDIT — home_widget, workmanager
AndroidManifest.xml                          # EDIT — 7 receiver + activity + action receiver
test/widget_bridge_test.dart                 # NEW — unit payload (opsional batch 1)
```

---

## 7. Urutan implementasi (vertical slice)

1. Fondasi `WidgetBridge` + palet + `schemaVersion`
2. **Today end-to-end** (layout, provider, manifest, deep link, toggle) — **checkpoint device**
3. Ekstrak `BaseWidgetProvider` + `WidgetTheme` + `WidgetData`
4. Compact + Priority
5. Dashboard
6. `QuickInputActivity` + MethodChannel → Quick Add & Quick Note — **checkpoint device**
7. Notes Today
8. WorkManager 30 menit
9. Theme light/dark/accent penuh
10. Hardening: corrupt payload, empty, reboot, logcat

---

## 8. Testing & acceptance

**Prinsip:** Batch 1 diterima via **manual checklist di device pribadi user** (bukan unit test sebagai gate utama).

Checklist:

- [ ] 7 widget muncul di picker launcher, grid benar
- [ ] Data match app (progress, list, jam, badge)
- [ ] Toggle dari widget sinkron dengan app
- [ ] Quick Add / Quick Note tersimpan; empty title ditolak
- [ ] Deep link ke screen tepat
- [ ] Ganti theme + accent → widget ikut
- [ ] Empty state rapi
- [ ] WorkManager / refresh tidak crash (logcat)
- [ ] Reboot → widget masih tampil data terakhir
- [ ] Device user (termasuk Android 14+ bila berlaku) tanpa crash widget
- [ ] Load 100+ task / 50+ note → list max baris, no overflow

**Success criteria Batch 1:** seluruh checklist ✅ + tidak ada crash widget pada pemakaian harian singkat → lanjut Batch 2 dengan pola sama.

Otomatisasi (opsional, bukan gate): unit test `WidgetBridge` payload builder.

---

## 9. Out of scope / Batch 2

- Notes List 4×4, Mini 1×1, Mini Note 1×1, Note Preview 4×2, widget referensi sisa
- iOS WidgetKit
- Screen konfigurasi widget per user (asumsi: layout fixed per widget)
- Jetpack Glance, cloud sync, tablet-specific layout

---

## 10. Risiko & mitigasi

| Risiko | Mitigasi |
|---|---|
| RemoteViews terbatas (EditText, radius, ring) | Overlay Activity utk input; ring via drawable/layer; accept limitasi visual |
| WorkManager ditunda OEM | Pemicu A/B; docs: buka app utk sync paling akurat |
| Duplikasi query lama vs bridge | Hanya WidgetBridge yang query; repo tetap source of truth |
| Crash provider (riwayat setProgressTintList) | try/catch onUpdate; hindari API bermasalah; test device nyata |
| `docs/` di .gitignore | Spec tetap ditulis di `docs/specs/`; commit dengan `git add -f` bila perlu |
