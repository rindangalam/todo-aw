/* Smoke test untuk demo statis todoaw — jalankan: node test/smoke.test.js */
'use strict';

const assert = require('node:assert');
const {
  makeSeedState,
  addTask,
  toggleTask,
  deleteTask,
  addNote,
  deleteNote,
  addHabit,
  deleteHabit,
  computeTodayProgress,
  computeStats,
  weeklyCounts,
  formatDateLabel,
  longDate,
  dateKey,
  addDays,
  sortTasks,
  todayTasks,
  filterTasks,
  groupTasks,
  CATEGORIES,
  LABELS,
  TEMPLATES,
  PRIORITY,
} = require('../js/demo.js');

const FIXED_DATE = new Date(2026, 7, 6, 10, 0, 0); // Kamis, 6 Agustus 2026
const TODAY = dateKey(FIXED_DATE);

let passed = 0;
function test(name, fn) {
  try {
    fn();
    passed++;
    console.log(`  ok  ${name}`);
  } catch (err) {
    console.error(`FAIL  ${name}`);
    console.error(err);
    process.exitCode = 1;
  }
}

/* ---------- seed ---------- */
let s = makeSeedState(FIXED_DATE);
test('seed: data awal ada (10 tugas, 3 catatan)', () => {
  assert.strictEqual(s.tasks.length, 10);
  assert.strictEqual(s.notes.length, 3);
});

test('seed: tugas hari ini = 3, 1 selesai', () => {
  const p = computeTodayProgress(s.tasks, TODAY);
  assert.strictEqual(p.total, 3); // laporan, olahraga sore, meeting
  assert.strictEqual(p.completed, 1);
  assert.strictEqual(p.percent, 1 / 3);
});

test('seed: streak = 3 (hari ini + 2 hari lalu)', () => {
  assert.strictEqual(computeStats(s.tasks, TODAY).streak, 3);
});

test('seed: statistik aktif = 7, selesai = 3, total = 10', () => {
  const st = computeStats(s.tasks, TODAY);
  assert.strictEqual(st.active, 7);
  assert.strictEqual(st.completed, 3);
  assert.strictEqual(st.total, 10);
});

/* ---------- add / toggle / delete ---------- */
test('addTask: tugas baru muncul di hari itu', () => {
  const t = { id: 'x1', title: 'Tes tugas', desc: '', priority: 'p1', categoryId: 'none', dueDate: TODAY, isCompleted: false, tags: [] };
  const s2 = addTask(s, t);
  assert.strictEqual(s2.tasks.length, 11);
  assert.strictEqual(todayTasks(s2.tasks, TODAY).length, 4);
});

test('toggleTask: centang tugas menaikkan progress', () => {
  const target = s.tasks.find((t) => t.dueDate === TODAY && !t.isCompleted);
  const s2 = toggleTask(s, target.id);
  const p = computeTodayProgress(s2.tasks, TODAY);
  assert.strictEqual(p.completed, 2);
  assert.strictEqual(p.percent, 2 / 3);
});

test('toggleTask: tidak mengubah state asli (immutable)', () => {
  const target = s.tasks.find((t) => t.dueDate === TODAY && !t.isCompleted);
  const before = s.tasks.find((t) => t.id === target.id).isCompleted;
  toggleTask(s, target.id);
  const after = s.tasks.find((t) => t.id === target.id).isCompleted;
  assert.strictEqual(before, after);
});

test('deleteTask: hapus tugas mengurangi total', () => {
  const target = s.tasks[0];
  const s2 = deleteTask(s, target.id);
  assert.strictEqual(s2.tasks.length, 9);
  assert.ok(!s2.tasks.some((t) => t.id === target.id));
});

test('addNote/deleteNote: catatan tambah & hapus', () => {
  let s2 = addNote(s, { id: 'n1', title: 'Catatan uji', body: 'isi', createdAt: TODAY });
  assert.strictEqual(s2.notes.length, 4);
  s2 = deleteNote(s2, 'n1');
  assert.strictEqual(s2.notes.length, 3);
});

test('addHabit/deleteHabit: kebiasaan tambah & hapus', () => {
  let s2 = addHabit(s, 'Minum air 8 gelas');
  assert.strictEqual(s2.habits.length, 1);
  const id = s2.habits[0].id;
  s2 = deleteHabit(s2, id);
  assert.strictEqual(s2.habits.length, 0);
});

/* ---------- grouping & filter ---------- */
test('groupTasks: Terlambat=2, Hari Ini=3, Besok=2, Nanti=3', () => {
  const g = groupTasks(s.tasks, TODAY);
  assert.strictEqual(g.overdue.length, 2); // Jogging pagi, Baca 10 halaman
  assert.strictEqual(g.today.length, 3); // laporan, olahraga, meeting
  assert.strictEqual(g.tomorrow.length, 2); // beli bahan, ganti password
  assert.strictEqual(g.later.length, 3); // mockup, refactor, baca artikel
});

test('filterTasks: status open → 7, prioritas p1 → 3', () => {
  assert.strictEqual(
    filterTasks(s.tasks, { status: 'open', priority: 'all', category: 'all', tags: [] }).length,
    7
  );
  assert.strictEqual(
    filterTasks(s.tasks, { status: 'all', priority: 'p1', category: 'all', tags: [] }).length,
    3
  );
});

test('filterTasks: kategori kerja → 4, label #F59E0B → 2', () => {
  assert.strictEqual(
    filterTasks(s.tasks, { status: 'all', priority: 'all', category: 'kerja', tags: [] }).length,
    4
  );
  assert.strictEqual(
    filterTasks(s.tasks, { status: 'all', priority: 'all', category: 'all', tags: ['#F59E0B'] }).length,
    2
  );
});

/* ---------- sorting ---------- */
test('sortTasks: belum selesai lebih dulu, deadline terdekat duluan', () => {
  const sorted = sortTasks(s.tasks);
  assert.strictEqual(sorted[0].isCompleted, false);
  assert.strictEqual(sorted[sorted.length - 1].isCompleted, true);
});

/* ---------- weekly & label ---------- */
test('weeklyCounts: Senin 3 Agu → Sel=1 (Baca 10 halaman), Kam=1 (Olahraga sore)', () => {
  const monday = addDays(TODAY, -3); // 3 Agu 2026 = Senin
  const counts = weeklyCounts(s.tasks, monday);
  assert.strictEqual(counts.length, 7);
  assert.strictEqual(counts[0], 0); // Senin
  assert.strictEqual(counts[1], 1); // Selasa: Baca 10 halaman buku
  assert.strictEqual(counts[3], 1); // Kamis: Olahraga sore
});

test('formatDateLabel: Hari Ini & Besok', () => {
  assert.strictEqual(formatDateLabel(TODAY, TODAY), 'Hari Ini');
  assert.strictEqual(formatDateLabel(addDays(TODAY, 1), TODAY), 'Besok');
});

test('formatDateLabel: tanggal lain pakai nama bulan', () => {
  assert.strictEqual(formatDateLabel('2026-08-20', TODAY), '20 Agustus');
});

/* ---------- konstanta ---------- */
test('konstanta: kategori & prioritas lengkap', () => {
  assert.strictEqual(CATEGORIES.length, 4);
  assert.ok(PRIORITY.p1 && PRIORITY.p2 && PRIORITY.p3 && PRIORITY.p4);
  assert.ok(TEMPLATES.length >= 3);
});

/* ---------- edge: semua selesai ---------- */
test('computeTodayProgress: 100% saat semua selesai', () => {
  const allDone = s.tasks.map((t) => ({ ...t, isCompleted: true }));
  const p = computeTodayProgress(allDone, TODAY);
  assert.strictEqual(p.percent, 1);
});

console.log(`\n${passed} test${passed > 1 ? 's' : ''} passed.`);
