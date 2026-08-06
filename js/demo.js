/* ============================================================
   todoaw — Demo Interaktif Statis (js/demo.js)
   Meniru UI app asli: Beranda, Kalender, Dashboard, Catatan,
   Pengaturan. Bagian "pure core" bisa diuji di Node.
   ============================================================ */
'use strict';

/* ---------------- helpers ---------------- */

function dateKey(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function parseKey(key) {
  const [y, m, d] = key.split('-').map(Number);
  return new Date(y, m - 1, d);
}

function addDays(key, n) {
  const d = parseKey(key);
  d.setDate(d.getDate() + n);
  return dateKey(d);
}

function uid() {
  return 'id' + Math.random().toString(36).slice(2, 10) + Date.now().toString(36);
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function hexToRgba(hex, alpha) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

const MONTHS = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const DAY_SHORT = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
const DAY_LONG = [
  'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
];

/* ---------------- pure core (testable di Node) ---------------- */

const PRIORITY = {
  p1: { label: 'P1', color: '#EF4444' },
  p2: { label: 'P2', color: '#F59E0B' },
  p3: { label: 'P3', color: '#3B82F6' },
  p4: { label: 'P4', color: '#9CA3AF' },
};

const PRIORITY_NAMES = { p1: 'Urgent', p2: 'Tinggi', p3: 'Sedang', p4: 'Rendah' };

const CATEGORIES = [
  { id: 'none', name: 'Tanpa Kategori', color: null },
  { id: 'kerja', name: 'Pekerjaan', color: '#3B82F6' },
  { id: 'rumah', name: 'Rumah', color: '#F59E0B' },
  { id: 'belajar', name: 'Belajar', color: '#8B5CF6' },
];

const LABELS = [
  { name: 'Pribadi', color: '#F59E0B' },
  { name: 'Pekerjaan', color: '#3B82F6' },
  { name: 'Penting', color: '#EF4444' },
  { name: 'Kesehatan', color: '#10B981' },
  { name: 'Belajar', color: '#8B5CF6' },
];

const TEMPLATES = [
  { title: 'Rutin Pagi', desc: 'Olahraga ringan, sarapan, cek jadwal' },
  { title: 'Belanja Mingguan', desc: 'Buat daftar belanja minggu ini' },
  { title: 'Review Mingguan', desc: 'Evaluasi progres minggu ini' },
  { title: 'Sprint Backlog', desc: 'Rinci task untuk sprint berikutnya' },
];

const NOTE_COLORS = ['#FDE68A', '#A7F3D0', '#BFDBFE', '#C7D2FE', '#FECACA', '#E2E8F0'];
const ACCENTS = ['#0EA5E9', '#8B5CF6', '#10B981', '#F59E0B', '#EF4444', '#EC4899'];
const STICKERS = [
  { e: '✨', n: 'Sparkle' }, { e: '☀️', n: 'Sun' }, { e: '🌙', n: 'Moon' },
  { e: '🌸', n: 'Flower' }, { e: '⭐', n: 'Star' }, { e: '❤️', n: 'Heart' },
  { e: '😊', n: 'Smile' }, { e: '⚡', n: 'Lightning' }, { e: '🎵', n: 'Music' },
  { e: '🎉', n: 'Party' },
];
const RECURRENCE = {
  '': 'Tidak berulang',
  daily: 'Setiap hari',
  weekly: 'Setiap minggu',
  monthly: 'Setiap bulan',
};

function makeSeedState(now) {
  const today = dateKey(now);
  const tomorrow = addDays(today, 1);
  const dayAfter = addDays(today, 2);
  const yesterday = addDays(today, -1);
  const twoDaysAgo = addDays(today, -2);

  const tasks = [
    { id: uid(), title: 'Beli bahan masakan', desc: 'Sayur, telur, dan bumbu dapur', priority: 'p1', categoryId: 'rumah', dueDate: tomorrow, isCompleted: false, tags: ['#F59E0B'], recurrence: '', reminder: 30, estimated: null, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Selesaikan laporan proyek', desc: 'Bab 3-5, lengkapi grafik dan kesimpulan', priority: 'p4', categoryId: 'kerja', dueDate: today, isCompleted: false, tags: ['#EF4444'], recurrence: '', reminder: 60, estimated: 120, subtasks: [
      { id: uid(), title: 'Tulis bab 3 & 4', done: true },
      { id: uid(), title: 'Buat grafik', done: false },
      { id: uid(), title: 'Review kesimpulan', done: false },
    ], archived: false, example: true },
    { id: uid(), title: 'Design mockup halaman login', desc: 'Buat 3 varian di Figma', priority: 'p3', categoryId: 'kerja', dueDate: dayAfter, isCompleted: false, tags: ['#8B5CF6'], recurrence: '', reminder: 30, estimated: 60, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Refactor API endpoint', desc: 'Pisahkan controller dan service layer', priority: 'p4', categoryId: 'kerja', dueDate: null, isCompleted: false, tags: ['#10B981'], recurrence: '', reminder: 30, estimated: null, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Olahraga sore', desc: 'Jogging 30 menit di taman', priority: 'p1', categoryId: 'none', dueDate: today, isCompleted: true, tags: [], recurrence: 'daily', reminder: 30, estimated: 30, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Baca artikel Flutter Riverpod', desc: 'https://docs-v2.riverpod.dev', priority: 'p1', categoryId: 'belajar', dueDate: null, isCompleted: false, tags: ['#EF4444'], recurrence: '', reminder: 30, estimated: null, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Ganti password wifi', desc: 'Buat password baru dan update di semua device', priority: 'p2', categoryId: 'rumah', dueDate: tomorrow, isCompleted: false, tags: ['#F59E0B'], recurrence: '', reminder: 30, estimated: 15, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Meeting tim', desc: '20 menit, bahas sprint review', priority: 'p2', categoryId: 'kerja', dueDate: today, isCompleted: false, tags: [], recurrence: 'weekly', reminder: 15, estimated: 20, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Jogging pagi', desc: '5 km di sekitar kompleks', priority: 'p3', categoryId: 'none', dueDate: yesterday, isCompleted: true, tags: [], recurrence: 'daily', reminder: 30, estimated: 30, subtasks: [], archived: false, example: true },
    { id: uid(), title: 'Baca 10 halaman buku', desc: 'Lanjut bab 4', priority: 'p4', categoryId: 'belajar', dueDate: twoDaysAgo, isCompleted: true, tags: [], recurrence: '', reminder: 30, estimated: null, subtasks: [], archived: false, example: true },
  ];

  const notes = [
    { id: uid(), title: 'Ide aplikasi', body: 'Integrasi widget home screen untuk quick add task', createdAt: today, color: '#FDE68A', pinned: true, example: true },
    { id: uid(), title: 'Grocery list', body: 'Telur, susu, kopi, sayur, dan sabun cuci piring', createdAt: yesterday, color: '#BFDBFE', pinned: false, example: true },
    { id: uid(), title: 'Belajar Flutter', body: 'Riverpod: provider vs notifier, AsyncValue states', createdAt: twoDaysAgo, color: '#A7F3D0', pinned: false, example: true },
  ];

  return {
    tasks,
    notes,
    habits: [],
    theme: 'system',
    accent: '#0EA5E9',
    sticker: '',
    filter: { status: 'all', priority: 'all', category: 'all', tags: [] },
  };
}

const sortPriority = (a, b) => {
  const order = { p1: 0, p2: 1, p3: 2, p4: 3 };
  return order[a] - order[b];
};

function sortTasks(tasks) {
  return [...tasks].sort((a, b) => {
    if (a.isCompleted !== b.isCompleted) return a.isCompleted ? 1 : -1;
    if (a.dueDate && b.dueDate) {
      if (a.dueDate !== b.dueDate) return a.dueDate < b.dueDate ? -1 : 1;
      return sortPriority(a.priority, b.priority);
    }
    if (!a.dueDate && !b.dueDate) return sortPriority(a.priority, b.priority);
    return a.dueDate ? -1 : 1;
  });
}

function addTask(state, task) {
  return { ...state, tasks: [...state.tasks, task] };
}

function toggleTask(state, id) {
  return {
    ...state,
    tasks: state.tasks.map((t) =>
      t.id === id ? { ...t, isCompleted: !t.isCompleted } : t
    ),
  };
}

function deleteTask(state, id) {
  return { ...state, tasks: state.tasks.filter((t) => t.id !== id) };
}

function addNote(state, note) {
  return { ...state, notes: [note, ...state.notes] };
}

function deleteNote(state, id) {
  return { ...state, notes: state.notes.filter((n) => n.id !== id) };
}

function addHabit(state, name) {
  return { ...state, habits: [...state.habits, { id: uid(), name }] };
}

function deleteHabit(state, id) {
  return { ...state, habits: state.habits.filter((h) => h.id !== id) };
}

function todayTasks(tasks, key) {
  return tasks.filter((t) => t.dueDate === key);
}

function computeTodayProgress(tasks, key) {
  const list = todayTasks(tasks, key);
  const total = list.length;
  const completed = list.filter((t) => t.isCompleted).length;
  return { total, completed, percent: total > 0 ? completed / total : 0 };
}

function computeStats(tasks, todayKey) {
  const completed = tasks.filter((t) => t.isCompleted).length;
  const total = tasks.length;
  let streak = 0;
  let day = todayKey;
  while (tasks.some((t) => t.isCompleted && t.dueDate === day)) {
    streak++;
    day = addDays(day, -1);
  }
  return { active: total - completed, completed, total, streak };
}

function weeklyCounts(tasks, mondayKey) {
  const counts = [];
  for (let i = 0; i < 7; i++) {
    const key = addDays(mondayKey, i);
    counts.push(tasks.filter((t) => t.isCompleted && t.dueDate === key).length);
  }
  return counts;
}

function mondayKeyOf(todayKey) {
  const d = parseKey(todayKey);
  d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
  return dateKey(d);
}

function formatDateLabel(key, todayKey) {
  if (key === todayKey) return 'Hari Ini';
  if (key === addDays(todayKey, 1)) return 'Besok';
  const d = parseKey(key);
  const diff = Math.round((d - parseKey(todayKey)) / 86400000);
  if (diff > 1 && diff < 7) return DAY_LONG[d.getDay()];
  return `${d.getDate()} ${MONTHS[d.getMonth()]}`;
}

function longDate(key) {
  const d = parseKey(key);
  return `${DAY_LONG[d.getDay()]}, ${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

function categoryOf(task) {
  return CATEGORIES.find((c) => c.id === task.categoryId) || CATEGORIES[0];
}

function labelNamesOf(task) {
  return (task.tags || [])
    .map((c) => LABELS.find((l) => l.color === c))
    .filter(Boolean);
}

function filterTasks(tasks, f) {
  return tasks.filter((t) => {
    if (f.status === 'open' && t.isCompleted) return false;
    if (f.status === 'done' && !t.isCompleted) return false;
    if (f.priority !== 'all' && t.priority !== f.priority) return false;
    if (f.category !== 'all' && t.categoryId !== f.category) return false;
    if (f.tags && f.tags.length && !f.tags.some((c) => (t.tags || []).includes(c))) return false;
    return true;
  });
}

function groupTasks(tasks, todayKey) {
  const groups = { overdue: [], today: [], tomorrow: [], later: [] };
  const tomorrow = addDays(todayKey, 1);
  tasks.forEach((t) => {
    if (!t.dueDate || t.dueDate > tomorrow) groups.later.push(t);
    else if (t.dueDate === todayKey) groups.today.push(t);
    else if (t.dueDate === tomorrow) groups.tomorrow.push(t);
    else groups.overdue.push(t);
  });
  return groups;
}

/* ---------------- UI layer (browser) ---------------- */

const LS_KEY = 'todoaw-demo-v1';
const RING_CIRC = 188.5; // r=30
const FOCUS_CIRC = 339.3; // r=54

let state = null;
let currentTab = 'home';
let selectedDayKey = null;
let calendarCursor = null;
let searchQ = '';
let noteSearchQ = null;
let editingTaskId = null;
let editingTags = [];
let editingCat = 'none';
let editingRecur = '';
let editingSubtasks = [];
let editingNoteId = null;
let editingNoteColor = null;
let stickerDraft = '';
let focusRemaining = 0;
let focusInterval = null;
let toastTimer = null;
let lastWeekCounts = [];
let swipe = null;

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

function saveState() {
  try {
    localStorage.setItem(LS_KEY, JSON.stringify(state));
  } catch (_) {
    /* localStorage tidak tersedia — abaikan */
  }
}

function loadState() {
  try {
    const raw = localStorage.getItem(LS_KEY);
    if (raw) return JSON.parse(raw);
  } catch (_) {
    /* ignore */
  }
  return null;
}

function migrateState(s) {
  s.tasks = (s.tasks || []).map((t) => ({
    recurrence: '', reminder: 30, estimated: null, subtasks: [], archived: false,
    ...t,
  }));
  s.notes = (s.notes || []).map((n) => ({ color: null, pinned: false, ...n }));
  s.habits = s.habits || [];
  s.theme = s.theme || 'system';
  s.accent = s.accent || '#0EA5E9';
  s.sticker = s.sticker || '';
  s.filter = s.filter || { status: 'all', priority: 'all', category: 'all', tags: [] };
  return s;
}

function toast(msg) {
  const el = $('#toast');
  el.textContent = msg;
  el.hidden = false;
  requestAnimationFrame(() => el.classList.add('show'));
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    el.classList.remove('show');
    setTimeout(() => { el.hidden = true; }, 300);
  }, 2200);
}

/* ---------- theme / accent ---------- */

function resolveTheme() {
  if (state.theme === 'system') {
    const dark =
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(prefers-color-scheme: dark)').matches;
    return dark ? 'dark' : 'light';
  }
  return state.theme;
}

function applyTheme() {
  const app = $('#app');
  app.dataset.theme = resolveTheme();
  document.body.classList.toggle('dark', resolveTheme() === 'dark');
  renderSettings();
}

function applyAccent() {
  const app = $('#app');
  app.style.setProperty('--accent', state.accent);
  app.style.setProperty('--accent-soft', hexToRgba(state.accent, 0.12));
  renderSettings();
}

function initRingGradient(id, ringEl) {
  const svg = ringEl.ownerSVGElement;
  if (!svg || svg.querySelector('defs')) return;
  const ns = 'http://www.w3.org/2000/svg';
  const defs = document.createElementNS(ns, 'defs');
  const g = document.createElementNS(ns, 'linearGradient');
  g.id = id;
  g.setAttribute('x1', '0');
  g.setAttribute('y1', '0');
  g.setAttribute('x2', '0');
  g.setAttribute('y2', '1');
  [['0%', '#EF4444'], ['33%', '#F59E0B'], ['66%', '#0EA5E9'], ['100%', '#10B981']]
    .forEach(([o, c]) => {
      const s = document.createElementNS(ns, 'stop');
      s.setAttribute('offset', o);
      s.setAttribute('stop-color', c);
      g.appendChild(s);
    });
  defs.appendChild(g);
  svg.insertBefore(defs, svg.firstChild);
  ringEl.setAttribute('stroke', `url(#${id})`);
}

/* ---------- task card HTML ---------- */

function priorityBadgeHTML(priority) {
  const p = PRIORITY[priority] || PRIORITY.p4;
  return `<span class="tc-priority ${priority}" style="color:${p.color};background:${hexToRgba(p.color, 0.14)}">${p.label}</span>`;
}

function taskCardHTML(task, todayKey) {
  const cat = categoryOf(task);
  const dotColor = cat.color
    ? `style="background:${cat.color}"`
    : `style="background:var(--muted);opacity:.4"`;
  const tagDots = (task.tags || [])
    .map((c) => `<span style="background:${c}"></span>`)
    .join('');
  const meta = [];
  if (task.dueDate) {
    meta.push(`<svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 11h-2V8h2v5zm-1 6a6 6 0 1 1 0-12 6 6 0 0 1 0 12z"/></svg>`);
    meta.push(`<span>${formatDateLabel(task.dueDate, todayKey)}</span>`);
  }
  if (task.subtasks && task.subtasks.length) {
    const done = task.subtasks.filter((s) => s.done).length;
    meta.push(`<span class="tc-sub">${done}/${task.subtasks.length} subtask</span>`);
  }
  return `
    <div class="task-card ${task.isCompleted ? 'done' : ''}" data-id="${task.id}">
      <button class="tc-check" data-act="toggle" aria-label="Selesaikan tugas">
        <svg viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z" stroke="#fff" stroke-width="2.4"/></svg>
      </button>
      <span class="tc-catdot" ${dotColor}></span>
      <div class="tc-main">
        <div class="tc-title">${escapeHtml(task.title)}</div>
        ${tagDots ? `<div class="tc-tags">${tagDots}</div>` : ''}
        ${meta.length ? `<div class="tc-meta">${meta.join('')}</div>` : ''}
      </div>
      ${priorityBadgeHTML(task.priority)}
      <svg class="tc-chevron" viewBox="0 0 24 24"><path d="M10 6 8.6 7.4 13.2 12l-4.6 4.6L10 18l6-6z"/></svg>
      <button class="tc-delete" data-act="delete" title="Hapus tugas">✕</button>
    </div>`;
}

function taskCardWrapperHTML(task, todayKey) {
  return `
    <div class="tc-swipe">
      <div class="tc-swipe-red">Hapus</div>
      ${taskCardHTML(task, todayKey)}
    </div>`;
}

function noteCardHTML(n, todayKey) {
  return `
    <div class="note-card ${n.pinned ? 'pinned' : ''}" data-id="${n.id}"
         style="background:${n.color || 'var(--surface)'}">
      ${n.pinned ? '<span class="note-pin" title="Disematkan">📌</span>' : ''}
      <div class="note-title">${escapeHtml(n.title)}</div>
      <div class="note-body">${escapeHtml(n.body)}</div>
      <div class="note-date">${formatDateLabel(n.createdAt, todayKey)}</div>
    </div>`;
}

/* ---------- renderers ---------- */

function renderAll() {
  renderHome();
  renderCalendar();
  renderDashboard();
  renderNotes();
  renderSettings();
  updateNav();
  updateFab();
}

function activeTasks() {
  return state.tasks.filter((t) => !t.archived);
}

function renderHome() {
  const todayKey = dateKey(new Date());
  const active = activeTasks();
  const { total, completed, percent } = computeTodayProgress(active, todayKey);
  const stats = computeStats(active, todayKey);

  $('#hero-ring').style.strokeDashoffset = RING_CIRC * (1 - percent);
  $('#hero-pct').textContent = `${Math.round(percent * 100)}%`;
  $('#hero-completed').textContent = completed;
  $('#hero-remaining').textContent = total - completed;

  const streakPill = $('#hero-streak');
  if (stats.streak > 0) {
    streakPill.hidden = false;
    $('#hero-streak-text').textContent = `${stats.streak} hari streak`;
  } else {
    streakPill.hidden = true;
  }

  const q = searchQ.trim().toLowerCase();
  let visible = active;
  if (q) {
    visible = visible.filter((t) =>
      t.title.toLowerCase().includes(q) || (t.desc || '').toLowerCase().includes(q)
    );
  }
  visible = filterTasks(visible, state.filter);

  const grouped = groupTasks(visible, todayKey);
  const sections = [
    ['Terlambat', grouped.overdue],
    ['Hari Ini', grouped.today],
    ['Besok', grouped.tomorrow],
    ['Nanti', grouped.later],
  ];

  let html = '';
  sections.forEach(([name, list]) => {
    if (!list.length) return;
    const sorted = sortTasks(list);
    html += `
      <div class="task-section">
        <div class="sec-head">
          <span>${name}</span>
          <span class="sec-count">${sorted.length}</span>
        </div>
        ${sorted.map((t) => taskCardWrapperHTML(t, todayKey)).join('')}
      </div>`;
  });
  $('#task-sections').innerHTML = html;
  bindSwipes($('#task-sections'));

  const emptyEl = $('#home-empty');
  if (visible.length === 0) {
    emptyEl.hidden = false;
    $('#home-empty-action').hidden = active.length > 0;
    if (active.length === 0) {
      $('#home-empty-title').textContent = 'Hari ini santai?';
      $('#home-empty-sub').textContent = 'Yuk, bikin tugas pertama';
    } else {
      $('#home-empty-title').textContent = 'Tidak ada tugas yang cocok';
      $('#home-empty-sub').textContent = 'Coba ubah filter atau kata kunci kamu';
    }
  } else {
    emptyEl.hidden = true;
  }

  $('#list-title').textContent = q ? 'Hasil Pencarian' : 'Daftar Tugas';
  renderFilterChips();
}

function renderCalendar() {
  const todayKey = dateKey(new Date());
  if (!calendarCursor) calendarCursor = parseKey(todayKey);
  if (!selectedDayKey) selectedDayKey = todayKey;
  const cursor = calendarCursor;

  $('#cal-month-label').textContent = `${MONTHS[cursor.getMonth()]} ${cursor.getFullYear()}`;

  const first = new Date(cursor.getFullYear(), cursor.getMonth(), 1);
  const offset = (first.getDay() + 6) % 7;
  const daysInMonth = new Date(cursor.getFullYear(), cursor.getMonth() + 1, 0).getDate();

  const taskKeys = new Set(activeTasks().filter((t) => t.dueDate).map((t) => t.dueDate));
  const cells = [];

  const prevDays = new Date(cursor.getFullYear(), cursor.getMonth(), 0).getDate();
  for (let i = offset - 1; i >= 0; i--) {
    const d = new Date(cursor.getFullYear(), cursor.getMonth() - 1, prevDays - i);
    cells.push(cellHTML(d, dateKey(d), true, taskKeys, todayKey));
  }
  for (let i = 1; i <= daysInMonth; i++) {
    const d = new Date(cursor.getFullYear(), cursor.getMonth(), i);
    cells.push(cellHTML(d, dateKey(d), false, taskKeys, todayKey));
  }
  const used = offset + daysInMonth;
  for (let i = 1; used + i <= 42; i++) {
    const d = new Date(cursor.getFullYear(), cursor.getMonth() + 1, i);
    cells.push(cellHTML(d, dateKey(d), true, taskKeys, todayKey));
  }

  $('#cal-grid').innerHTML = cells.join('');
  renderAgenda();
}

function cellHTML(d, key, other, taskKeys, todayKey) {
  const cls = [
    'cal-day',
    other ? 'other' : '',
    key === todayKey ? 'today' : '',
    key === selectedDayKey && key !== todayKey ? 'selected' : '',
  ].filter(Boolean).join(' ');
  const dot = taskKeys.has(key) ? '<span class="cal-dot"></span>' : '';
  return `<button class="${cls}" data-day="${key}">${d.getDate()}${dot}</button>`;
}

function renderAgenda() {
  const todayKey = dateKey(new Date());
  const key = selectedDayKey || todayKey;
  const tasks = activeTasks().filter((t) => t.dueDate === key);

  $('#agenda-title').textContent = longDate(key);
  $('#agenda-today').hidden = key !== todayKey;

  const countEl = $('#agenda-count');
  const listEl = $('#agenda-list');
  const emptyEl = $('#agenda-empty');

  if (tasks.length === 0) {
    countEl.hidden = true;
    listEl.innerHTML = '';
    emptyEl.hidden = false;
  } else {
    const done = tasks.filter((t) => t.isCompleted).length;
    countEl.hidden = false;
    $('#agenda-count-left').textContent = `${done} tugas selesai`;
    $('#agenda-count-right').textContent = `${done}/${tasks.length}`;
    listEl.innerHTML = sortTasks(tasks).map((t) => taskCardWrapperHTML(t, todayKey)).join('');
    emptyEl.hidden = true;
  }
  bindSwipes(listEl);
}

function renderDaySheet(key) {
  const todayKey = dateKey(new Date());
  const tasks = activeTasks().filter((t) => t.dueDate === key);
  $('#day-title').textContent = longDate(key);
  $('#day-tasks').innerHTML = tasks.length
    ? sortTasks(tasks).map((t) => taskCardWrapperHTML(t, todayKey)).join('')
    : '<div class="sheet-empty">Tidak ada tugas di hari ini</div>';
  bindSwipes($('#day-tasks'));
  openSheet('sheet-day');
}

function renderDashboard() {
  const todayKey = dateKey(new Date());
  const active = activeTasks();
  const { total, completed, percent } = computeTodayProgress(active, todayKey);
  const stats = computeStats(active, todayKey);

  $('#dash-ring').style.strokeDashoffset = RING_CIRC * (1 - percent);
  $('#dash-pct').textContent = `${Math.round(percent * 100)}%`;
  $('#dash-count').textContent = `${completed}/${total} tugas hari ini`;
  const bar = $('#dash-bar');
  bar.style.width = `${Math.round(percent * 100)}%`;

  const counts = weeklyCounts(active, mondayKeyOf(todayKey));
  lastWeekCounts = counts;
  const max = Math.max(...counts, 1);
  $('#week-chart').innerHTML = counts
    .map((c, i) => {
      const h = c > 0 ? 14 + Math.round((c / max) * 78) : 5;
      return `
        <div class="wc-col" data-i="${i}" title="${DAY_SHORT[(i + 1) % 7]}: ${c} tugas">
          <span class="wc-val">${c > 0 ? c : ''}</span>
          <div class="wc-bar ${c > 0 ? 'fill' : ''}" style="height:${h}px"></div>
          <span class="wc-label">${DAY_SHORT[(i + 1) % 7]}</span>
        </div>`;
    })
    .join('');

  $('#stat-active').textContent = stats.active;
  $('#stat-done').textContent = stats.completed;
  $('#stat-total').textContent = stats.total;

  $('#streak-title').textContent = `${stats.streak} hari streak`;
  $('#streak-sub').textContent =
    stats.streak > 0
      ? stats.streak === 1
        ? 'Kemarin aktif'
        : `${stats.streak} hari berturut-turut aktif`
      : 'Mulai streak-mu hari ini!';
}

function renderNotes() {
  const todayKey = dateKey(new Date());
  let list = state.notes;
  if (noteSearchQ) {
    const q = noteSearchQ.toLowerCase();
    list = list.filter(
      (n) => n.title.toLowerCase().includes(q) || n.body.toLowerCase().includes(q)
    );
  }
  const pinned = list.filter((n) => n.pinned);
  const rest = list
    .filter((n) => !n.pinned)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));

  $('#pin-head').hidden = pinned.length === 0;
  $('#notes-grid').innerHTML = [...pinned, ...rest]
    .map((n) => noteCardHTML(n, todayKey))
    .join('');
  $('#notes-empty').hidden = list.length > 0;
}

function renderHabits() {
  const listEl = $('#habit-list');
  if (state.habits.length === 0) {
    listEl.innerHTML = '<div class="sheet-empty">Belum ada kebiasaan</div>';
    return;
  }
  listEl.innerHTML = state.habits
    .map(
      (h) => `
      <div class="habit-item" data-id="${h.id}">
        <span class="habit-ico">🔁</span>
        <span class="habit-name">${escapeHtml(h.name)}</span>
        <button class="habit-del" data-del="${h.id}">✕</button>
      </div>`
    )
    .join('');
}

function renderSettings() {
  $$('.set-row[data-mode]').forEach((row) => {
    const check = row.querySelector('.set-check');
    if (check) check.classList.toggle('on', row.dataset.mode === state.theme);
  });
  $('#accent-hex').textContent = state.accent.toUpperCase();
  $('#accent-swatch').style.background = state.accent;
  $('#sticker-preview').textContent = state.sticker || '🚫';
  const preset = STICKERS.find((s) => s.e === state.sticker);
  $('#sticker-label').textContent = !state.sticker
    ? 'Tanpa Stiker'
    : preset
      ? preset.n
      : 'Stiker kustom';
}

function renderFilterChips() {
  const f = state.filter;
  const chips = [];
  if (f.status === 'open') chips.push({ label: 'Belum Selesai', clear: 'status' });
  if (f.status === 'done') chips.push({ label: 'Selesai', clear: 'status' });
  if (f.priority !== 'all') chips.push({ label: PRIORITY[f.priority].label, clear: 'priority' });
  if (f.category !== 'all') {
    const cat = CATEGORIES.find((c) => c.id === f.category) || CATEGORIES[0];
    chips.push({ label: cat.name, clear: 'category' });
  }
  (f.tags || []).forEach((c) => {
    const l = LABELS.find((x) => x.color === c);
    chips.push({ label: l ? l.name : c, color: c, clear: 'tag:' + c });
  });
  $('#filter-chips').innerHTML = chips
    .map(
      (c) => `
      <button class="filter-chip" data-clear="${c.clear}">
        ${c.color ? `<span class="fdot" style="background:${c.color}"></span>` : ''}
        ${escapeHtml(c.label)}
        <span class="fdot-x">✕</span>
      </button>`
    )
    .join('');
}

function clearFilter(key) {
  const f = state.filter;
  if (key === 'status') f.status = 'all';
  else if (key === 'priority') f.priority = 'all';
  else if (key === 'category') f.category = 'all';
  else if (key.startsWith('tag:')) f.tags = (f.tags || []).filter((c) => c !== key.slice(4));
  saveState();
  renderHome();
}

/* ---------- nav / fab ---------- */

function setTab(tab) {
  currentTab = tab;
  renderAll();
}

function updateNav() {
  $$('.nav-item').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.tab === currentTab);
  });
  $$('.screen').forEach((s) => {
    s.hidden = s.id !== `screen-${currentTab}`;
  });
}

function updateFab() {
  $('#fab').classList.toggle('hidden', currentTab !== 'home' && currentTab !== 'notes');
}

/* ---------- sheets ---------- */

function openSheet(id) {
  $$('.sheet').forEach((s) => { s.hidden = s.id !== id; });
  const backdrop = $('#sheet-backdrop');
  backdrop.hidden = false;
  requestAnimationFrame(() => backdrop.classList.add('open'));
}

function closeSheet() {
  const backdrop = $('#sheet-backdrop');
  backdrop.classList.remove('open');
  setTimeout(() => { backdrop.hidden = true; }, 280);
}

/* ---------- task form ---------- */

function renderPriorityChips(selected) {
  $$('#tf-priority .prio-chip').forEach((chip) => {
    chip.classList.toggle('sel', chip.dataset.priority === selected);
  });
}

function renderTagChips() {
  $('#tf-tags').innerHTML = LABELS.map((l) => {
    const sel = editingTags.includes(l.color);
    return `
      <button class="tag-chip ${sel ? 'sel' : ''}" data-tag="${l.color}"
        style="${sel ? `background:${l.color};border-color:${l.color};color:#fff` : ''}">
        <span class="prio-dot" style="background:${l.color}"></span>${l.name}
      </button>`;
  }).join('');
}

function renderCatMenu() {
  $('#tf-cat-menu').innerHTML = CATEGORIES.map(
    (c) => `
      <button class="select-item" data-cat="${c.id}">
        <span class="prio-dot" style="background:${c.color || '#CBD5E1'}"></span>${c.name}
      </button>`
  ).join('');
}

function setCatValue(id) {
  const cat = CATEGORIES.find((c) => c.id === id) || CATEGORIES[0];
  $('#tf-cat-value').innerHTML =
    `<span class="prio-dot" style="background:${cat.color || '#CBD5E1'}"></span>${cat.name}`;
}

function renderSubtasks() {
  $('#tf-subtasks').innerHTML = editingSubtasks
    .map(
      (s) => `
      <div class="subtask-item">
        <button class="subtask-check ${s.done ? 'on' : ''}" data-sub="${s.id}" aria-label="Centang subtask">
          <svg viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4z"/></svg>
        </button>
        <span class="${s.done ? 'done' : ''}">${escapeHtml(s.title)}</span>
        <button class="subtask-del" data-sub="${s.id}" title="Hapus subtask">✕</button>
      </div>`
    )
    .join('');
}

function openTaskSheet(task) {
  editingTaskId = task ? task.id : null;
  $('#sheet-task-title').textContent = task ? 'Edit Tugas' : 'Tugas Baru';
  $('#tf-title').value = task ? task.title : '';
  $('#tf-count').textContent = `${$('#tf-title').value.length}/80`;
  $('#tf-desc').value = task ? (task.desc || '') : '';
  renderPriorityChips(task ? task.priority : 'p3');
  editingCat = task ? (task.categoryId || 'none') : 'none';
  setCatValue(editingCat);
  $('#tf-cat-menu').hidden = true;
  editingTags = task ? [...(task.tags || [])] : [];
  renderTagChips();
  editingRecur = task ? (task.recurrence || '') : '';
  $('#tf-recur-value').textContent = RECURRENCE[editingRecur] || RECURRENCE[''];
  $('#tf-recur-menu').hidden = true;
  $('#tf-date').value = task && task.dueDate ? task.dueDate : '';
  $('#tf-date').hidden = true;
  $('#tf-date-value').textContent =
    task && task.dueDate ? shortDate(task.dueDate) : 'Pilih tanggal';
  $('#tf-reminder').value = String(task && task.reminder != null ? task.reminder : 30);
  $('#tf-estimated').value = task && task.estimated != null ? String(task.estimated) : '';
  editingSubtasks = task ? [...(task.subtasks || [])] : [];
  $('#edit-only').hidden = !task;
  renderSubtasks();
  openSheet('sheet-task');
}

function shortDate(key) {
  const d = parseKey(key);
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

function openTaskSheetFromTemplate(tpl) {
  openTaskSheet(null);
  $('#tf-title').value = tpl.title;
  $('#tf-count').textContent = `${tpl.title.length}/80`;
  $('#tf-desc').value = tpl.desc || '';
}

function saveTaskFromForm() {
  const title = $('#tf-title').value.trim();
  if (!title) {
    toast('Judul wajib diisi');
    return;
  }
  const priority = $('#tf-priority .prio-chip.sel')?.dataset.priority || 'p3';
  const dueDate = $('#tf-date').value || null;
  const data = {
    title,
    desc: $('#tf-desc').value.trim(),
    priority,
    categoryId: editingCat,
    dueDate,
    tags: editingTags,
    recurrence: editingRecur,
    reminder: parseInt($('#tf-reminder').value, 10) || 30,
    estimated: $('#tf-estimated').value ? parseInt($('#tf-estimated').value, 10) : null,
    subtasks: editingSubtasks,
  };

  if (editingTaskId) {
    state = {
      ...state,
      tasks: state.tasks.map((t) =>
        t.id === editingTaskId ? { ...t, ...data } : t
      ),
    };
  } else {
    state = addTask(state, { id: uid(), isCompleted: false, archived: false, ...data });
  }
  saveState();
  closeSheet();
  renderAll();
}

/* ---------- template picker ---------- */

function renderTemplates() {
  $('#template-list').innerHTML = TEMPLATES.map(
    (t) => `
      <div class="tpl-item" data-id="${t.title}">
        <span class="tpl-ico">
          <svg viewBox="0 0 24 24"><path d="M17 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2zm-5 14.5L6.5 13l1.4-1.4L12 14.7l4.1-4.1L17.5 12 12 17.5z"/></svg>
        </span>
        <div>
          <div class="tpl-title">${t.title}</div>
          <div class="tpl-sub">${t.desc}</div>
        </div>
      </div>`
  ).join('');
}

/* ---------- note form ---------- */

function renderNoteColors() {
  $('#nf-colors').innerHTML = `
    <button class="color-dot none ${!editingNoteColor ? 'sel' : ''}" data-color="" title="Tanpa warna"
      style="background:var(--surface);border-color:var(--line)"></button>` +
    NOTE_COLORS.map(
      (c) =>
        `<button class="color-dot ${c === editingNoteColor ? 'sel' : ''}" data-color="${c}"
           style="background:${c}"></button>`
    ).join('');
}

function openNoteSheet(note) {
  editingNoteId = note ? note.id : null;
  editingNoteColor = note ? (note.color || null) : null;
  $('#sheet-note-title').textContent = note ? 'Edit Catatan' : 'Catatan Baru';
  $('#nf-title').value = note ? note.title : '';
  $('#nf-body').value = note ? note.body : '';
  $('#nf-pin').checked = !!(note && note.pinned);
  $('#nf-save').textContent = note ? 'Simpan' : 'Tambah';
  renderNoteColors();
  openSheet('sheet-note');
}

function saveNoteFromForm() {
  const title = $('#nf-title').value.trim();
  if (!title) {
    toast('Judul catatan wajib diisi');
    return;
  }
  const body = $('#nf-body').value.trim();
  const data = {
    title,
    body,
    color: editingNoteColor,
    pinned: $('#nf-pin').checked,
  };
  if (editingNoteId) {
    state = {
      ...state,
      notes: state.notes.map((n) =>
        n.id === editingNoteId ? { ...n, ...data } : n
      ),
    };
  } else {
    state = addNote(state, { id: uid(), createdAt: dateKey(new Date()), ...data });
  }
  saveState();
  closeSheet();
  renderNotes();
}

/* ---------- filter sheet ---------- */

let draftFilter = null;

function renderFilterSheet() {
  const f = draftFilter;
  const statusChips = [
    ['all', 'Semua'],
    ['open', 'Belum Selesai'],
    ['done', 'Selesai'],
  ];
  $('#filter-status').innerHTML = statusChips
    .map(([v, l]) => `<button class="chip ${f.status === v ? 'sel' : ''}" data-status="${v}">${l}</button>`)
    .join('');

  $('#filter-priority').innerHTML =
    `<button class="chip ${f.priority === 'all' ? 'sel' : ''}" data-priority="all">Semua</button>` +
    Object.entries(PRIORITY)
      .map(([k, p]) =>
        `<button class="chip ${f.priority === k ? 'sel' : ''}" data-priority="${k}">
           <span class="prio-dot" style="background:${p.color}"></span>${PRIORITY_NAMES[k]}
         </button>`
      )
      .join('');

  $('#filter-category').innerHTML =
    `<button class="chip ${f.category === 'all' ? 'sel' : ''}" data-cat="all">Semua</button>` +
    CATEGORIES.filter((c) => c.id !== 'none')
      .map((c) =>
        `<button class="chip ${f.category === c.id ? 'sel' : ''}" data-cat="${c.id}">
           <span class="prio-dot" style="background:${c.color}"></span>${c.name}
         </button>`
      )
      .join('');

  $('#filter-tags').innerHTML =
    `<button class="chip ${!f.tags || !f.tags.length ? 'sel' : ''}" data-tag="all">Semua</button>` +
    LABELS.map((l) =>
      `<button class="chip ${(f.tags || []).includes(l.color) ? 'sel' : ''}" data-tag="${l.color}">
         <span class="prio-dot" style="background:${l.color}"></span>${l.name}
       </button>`
    ).join('');
}

/* ---------- sticker / accent ---------- */

function renderStickerGrid() {
  $('#sticker-grid').innerHTML = STICKERS.map(
    (s) => `
      <button class="sticker-item ${s.e === stickerDraft ? 'sel' : ''}" data-sticker="${s.e}"
        title="${s.n}">${s.e}</button>`
  ).join('');
}

function openStickerSheet() {
  stickerDraft = state.sticker || '';
  $('#sticker-text').value = STICKERS.some((s) => s.e === stickerDraft) ? '' : stickerDraft;
  $('#sticker-preview-box').textContent = stickerDraft || '✨';
  renderStickerGrid();
  openSheet('sheet-sticker');
}

function renderAccentGrid() {
  $('#accent-grid').innerHTML = ACCENTS.map(
    (c) =>
      `<button class="accent-dot ${c === state.accent ? 'sel' : ''}" data-accent="${c}"
         style="background:${c}"></button>`
  ).join('');
}

/* ---------- focus timer ---------- */

function renderFocusTimer() {
  const total = 25 * 60;
  const m = Math.floor(focusRemaining / 60).toString().padStart(2, '0');
  const s = (focusRemaining % 60).toString().padStart(2, '0');
  $('#focus-time').textContent = `${m}:${s}`;
  const progress = total > 0 ? focusRemaining / total : 0;
  $('#focus-ring').style.strokeDashoffset = FOCUS_CIRC * (1 - progress);
  $('#focus-start').textContent = focusInterval ? 'Jeda' : 'Mulai';
}

function toggleFocus() {
  if (focusInterval) {
    clearInterval(focusInterval);
    focusInterval = null;
  } else {
    if (focusRemaining <= 0) focusRemaining = 25 * 60;
    focusInterval = setInterval(() => {
      focusRemaining--;
      if (focusRemaining <= 0) {
        clearInterval(focusInterval);
        focusInterval = null;
        focusRemaining = 0;
        toast('Fokus selesai! 🎉');
      }
      renderFocusTimer();
    }, 1000);
  }
  renderFocusTimer();
}

function resetFocus() {
  clearInterval(focusInterval);
  focusInterval = null;
  focusRemaining = 25 * 60;
  renderFocusTimer();
}

/* ---------- swipe to delete ---------- */

function bindSwipes(container) {
  if (!container) return;
  container.querySelectorAll('.task-card').forEach((card) => {
    card.addEventListener('pointerdown', onSwipeDown, { passive: true });
  });
}

function onSwipeDown(e) {
  if (e.button !== 0) return;
  const card = e.target.closest('.task-card');
  if (!card) return;
  swipe = { card, startX: e.clientX, dx: 0, active: false };
  window.addEventListener('pointermove', onSwipeMove, { passive: true });
  window.addEventListener('pointerup', onSwipeUp);
}

function onSwipeMove(e) {
  if (!swipe) return;
  const dx = e.clientX - swipe.startX;
  if (!swipe.active && Math.abs(dx) > 10) swipe.active = true;
  if (swipe.active) {
    swipe.dx = dx;
    swipe.card.style.transition = 'none';
    swipe.card.style.transform = `translateX(${dx}px)`;
  }
}

function onSwipeUp() {
  const s = swipe;
  swipe = null;
  window.removeEventListener('pointermove', onSwipeMove);
  window.removeEventListener('pointerup', onSwipeUp);
  if (!s) return;
  if (!s.active) {
    s.card.style.transform = '';
    return;
  }
  s.card.dataset.swiped = '1';
  setTimeout(() => { delete s.card.dataset.swiped; }, 150);
  if (s.dx < -64) {
    const id = s.card.dataset.id;
    s.card.style.transition = 'transform .25s ease';
    s.card.style.transform = 'translateX(-120%)';
    setTimeout(() => {
      state = deleteTask(state, id);
      saveState();
      renderAll();
      toast('Tugas dihapus');
    }, 240);
  } else {
    s.card.style.transition = 'transform .2s ease';
    s.card.style.transform = '';
    setTimeout(() => { s.card.style.transition = ''; }, 200);
  }
}

/* ---------- interactions ---------- */

function onTaskCardClick(e) {
  const card = e.target.closest('.task-card');
  if (!card) return;
  if (card.dataset.swiped === '1') {
    card.dataset.swiped = '';
    return;
  }
  const toggleBtn = e.target.closest('[data-act="toggle"]');
  const delBtn = e.target.closest('[data-act="delete"]');
  if (toggleBtn) {
    state = toggleTask(state, card.dataset.id);
    saveState();
    renderAll();
    return;
  }
  if (delBtn) {
    state = deleteTask(state, card.dataset.id);
    saveState();
    renderAll();
    toast('Tugas dihapus');
    return;
  }
  const task = state.tasks.find((t) => t.id === card.dataset.id);
  if (task) openTaskSheet(task);
}

function toggleNoteSearch() {
  const existing = $('#notes-search-box');
  if (existing) {
    existing.remove();
    noteSearchQ = null;
    renderNotes();
    return;
  }
  const box = document.createElement('div');
  box.id = 'notes-search-box';
  box.className = 'notes-search';
  box.innerHTML = '<input type="text" placeholder="Cari catatan..." autofocus>';
  box.querySelector('input').addEventListener('input', (e) => {
    noteSearchQ = e.target.value.trim();
    renderNotes();
  });
  $('#pin-head').parentElement.insertBefore(box, $('#pin-head'));
  renderNotes();
  box.querySelector('input').focus();
}

function bindEvents() {
  /* nav */
  $$('.nav-item').forEach((btn) => {
    btn.addEventListener('click', () => setTab(btn.dataset.tab));
  });

  /* fab */
  $('#fab').addEventListener('click', () => {
    if (currentTab === 'notes') openNoteSheet();
    else openTaskSheet();
  });

  /* quick actions */
  $('#qa-task').addEventListener('click', () => openTaskSheet());
  $('#qa-template').addEventListener('click', () => {
    renderTemplates();
    openSheet('sheet-template');
  });
  $('#qa-note').addEventListener('click', () => {
    setTab('notes');
    openNoteSheet();
  });
  $('#qa-focus').addEventListener('click', () => {
    resetFocus();
    openSheet('sheet-focus');
  });
  $('#qa-habit').addEventListener('click', () => {
    renderHabits();
    openSheet('sheet-habit');
  });
  $('#home-empty-action').addEventListener('click', () => openTaskSheet());

  /* search (home) */
  $('#btn-search').addEventListener('click', () => {
    const input = $('#search-input');
    if (input.hidden) {
      input.hidden = false;
      input.focus();
    } else {
      input.hidden = true;
      input.value = '';
      searchQ = '';
      renderHome();
    }
  });
  $('#search-input').addEventListener('input', (e) => {
    searchQ = e.target.value;
    renderHome();
  });

  /* filter (home) */
  $('#btn-filter').addEventListener('click', () => {
    draftFilter = {
      status: state.filter.status,
      priority: state.filter.priority,
      category: state.filter.category,
      tags: [...(state.filter.tags || [])],
    };
    renderFilterSheet();
    openSheet('sheet-filter');
  });
  $('#filter-reset').addEventListener('click', () => {
    draftFilter = { status: 'all', priority: 'all', category: 'all', tags: [] };
    renderFilterSheet();
  });
  $('#filter-apply').addEventListener('click', () => {
    state.filter = draftFilter;
    saveState();
    closeSheet();
    renderHome();
  });
  $('#filter-chips').addEventListener('click', (e) => {
    const chip = e.target.closest('[data-clear]');
    if (chip) clearFilter(chip.dataset.clear);
  });
  $('#sheet-filter .sheet-body').addEventListener('click', (e) => {
    const st = e.target.closest('[data-status]');
    if (st) { draftFilter.status = st.dataset.status; renderFilterSheet(); return; }
    const pr = e.target.closest('[data-priority]');
    if (pr) { draftFilter.priority = pr.dataset.priority; renderFilterSheet(); return; }
    const cat = e.target.closest('[data-cat]');
    if (cat) { draftFilter.category = cat.dataset.cat; renderFilterSheet(); return; }
    const tag = e.target.closest('[data-tag]');
    if (tag) {
      if (tag.dataset.tag === 'all') draftFilter.tags = [];
      else {
        const arr = draftFilter.tags || [];
        draftFilter.tags = arr.includes(tag.dataset.tag)
          ? arr.filter((c) => c !== tag.dataset.tag)
          : [...arr, tag.dataset.tag];
      }
      renderFilterSheet();
    }
  });

  /* task lists (delegated) */
  ['#task-sections', '#agenda-list', '#day-tasks'].forEach((sel) => {
    document.querySelector(sel).addEventListener('click', onTaskCardClick);
  });

  /* calendar */
  $('#cal-prev').addEventListener('click', () => {
    calendarCursor = new Date(calendarCursor.getFullYear(), calendarCursor.getMonth() - 1, 1);
    renderCalendar();
  });
  $('#cal-next').addEventListener('click', () => {
    calendarCursor = new Date(calendarCursor.getFullYear(), calendarCursor.getMonth() + 1, 1);
    renderCalendar();
  });
  $('#cal-today').addEventListener('click', () => {
    calendarCursor = parseKey(dateKey(new Date()));
    selectedDayKey = dateKey(new Date());
    renderCalendar();
  });
  $('#cal-grid').addEventListener('click', (e) => {
    const cell = e.target.closest('[data-day]');
    if (!cell) return;
    selectedDayKey = cell.dataset.day;
    renderCalendar();
    renderDaySheet(selectedDayKey);
  });

  /* week chart */
  $('#week-chart').addEventListener('click', (e) => {
    const col = e.target.closest('[data-i]');
    if (!col) return;
    const i = parseInt(col.dataset.i, 10);
    const count = lastWeekCounts[i] || 0;
    toast(`${DAY_SHORT[(i + 1) % 7]}: ${count} tugas`);
  });

  /* sheet backdrop + close buttons */
  $('#sheet-backdrop').addEventListener('click', (e) => {
    if (e.target.closest('[data-close]')) closeSheet();
  });

  /* task form */
  $('#tf-priority').addEventListener('click', (e) => {
    const chip = e.target.closest('[data-priority]');
    if (chip) renderPriorityChips(chip.dataset.priority);
  });
  $('#tf-tags').addEventListener('click', (e) => {
    const chip = e.target.closest('[data-tag]');
    if (!chip) return;
    const color = chip.dataset.tag;
    editingTags = editingTags.includes(color)
      ? editingTags.filter((c) => c !== color)
      : [...editingTags, color];
    renderTagChips();
  });
  $('#tf-cat-toggle').addEventListener('click', (e) => {
    e.stopPropagation();
    const menu = $('#tf-cat-menu');
    $('#tf-recur-menu').hidden = true;
    menu.hidden = !menu.hidden;
  });
  $('#tf-cat-menu').addEventListener('click', (e) => {
    const item = e.target.closest('[data-cat]');
    if (!item) return;
    editingCat = item.dataset.cat;
    setCatValue(editingCat);
    $('#tf-cat-menu').hidden = true;
  });
  $('#tf-recur-toggle').addEventListener('click', (e) => {
    e.stopPropagation();
    const menu = $('#tf-recur-menu');
    $('#tf-cat-menu').hidden = true;
    menu.hidden = !menu.hidden;
  });
  $('#tf-recur-menu').addEventListener('click', (e) => {
    const item = e.target.closest('[data-recur]');
    if (!item) return;
    editingRecur = item.dataset.recur;
    $('#tf-recur-value').textContent = RECURRENCE[editingRecur];
    $('#tf-recur-menu').hidden = true;
  });
  document.addEventListener('click', () => {
    $('#tf-cat-menu').hidden = true;
    $('#tf-recur-menu').hidden = true;
  });
  $('#tf-date-toggle').addEventListener('click', () => {
    const input = $('#tf-date');
    input.hidden = false;
    input.focus();
    if (input.showPicker) input.showPicker();
  });
  $('#tf-date').addEventListener('change', (e) => {
    const v = e.target.value;
    e.target.hidden = true;
    $('#tf-date-value').textContent = v ? shortDate(v) : 'Pilih tanggal';
  });
  $('#tf-title').addEventListener('input', (e) => {
    $('#tf-count').textContent = `${e.target.value.length}/80`;
  });
  $('#tf-title').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') saveTaskFromForm();
  });
  $('#tf-subtask-add').addEventListener('click', () => {
    const input = $('#tf-subtask-input');
    const title = input.value.trim();
    if (!title) return;
    editingSubtasks = [...editingSubtasks, { id: uid(), title, done: false }];
    input.value = '';
    renderSubtasks();
  });
  $('#tf-subtask-input').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') $('#tf-subtask-add').click();
  });
  $('#tf-subtasks').addEventListener('click', (e) => {
    const check = e.target.closest('.subtask-check');
    const del = e.target.closest('.subtask-del');
    if (check) {
      const id = check.dataset.sub;
      editingSubtasks = editingSubtasks.map((s) =>
        s.id === id ? { ...s, done: !s.done } : s
      );
      renderSubtasks();
    } else if (del) {
      const id = del.dataset.sub;
      editingSubtasks = editingSubtasks.filter((s) => s.id !== id);
      renderSubtasks();
    }
  });
  $('#tf-save').addEventListener('click', saveTaskFromForm);
  $('#tf-archive').addEventListener('click', () => {
    if (!editingTaskId) return;
    state = {
      ...state,
      tasks: state.tasks.map((t) =>
        t.id === editingTaskId ? { ...t, archived: true } : t
      ),
    };
    saveState();
    closeSheet();
    renderAll();
    toast('Tugas diarsipkan');
  });
  $('#tf-template').addEventListener('click', () => {
    toast('Disimpan sebagai template');
  });

  /* template picker */
  $('#template-list').addEventListener('click', (e) => {
    const item = e.target.closest('[data-id]');
    if (!item) return;
    const tpl = TEMPLATES.find((t) => t.title === item.dataset.id);
    if (!tpl) return;
    closeSheet();
    openTaskSheetFromTemplate(tpl);
  });

  /* notes */
  $('#btn-note-search').addEventListener('click', toggleNoteSearch);
  $('#notes-grid').addEventListener('click', (e) => {
    const card = e.target.closest('.note-card');
    if (!card) return;
    const note = state.notes.find((n) => n.id === card.dataset.id);
    if (note) openNoteSheet(note);
  });
  $('#nf-save').addEventListener('click', saveNoteFromForm);
  $('#nf-colors').addEventListener('click', (e) => {
    const dot = e.target.closest('[data-color]');
    if (!dot) return;
    editingNoteColor = dot.dataset.color || null;
    renderNoteColors();
  });

  /* habits */
  $('#habit-add').addEventListener('click', () => {
    const input = $('#habit-input');
    const name = input.value.trim();
    if (!name) {
      toast('Nama kebiasaan wajib diisi');
      return;
    }
    state = addHabit(state, name);
    input.value = '';
    saveState();
    renderHabits();
    toast('Kebiasaan ditambahkan');
  });
  $('#habit-input').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') $('#habit-add').click();
  });
  $('#habit-list').addEventListener('click', (e) => {
    const btn = e.target.closest('[data-del]');
    if (!btn) return;
    state = deleteHabit(state, btn.dataset.del);
    saveState();
    renderHabits();
  });

  /* focus */
  $('#focus-start').addEventListener('click', toggleFocus);
  $('#focus-reset').addEventListener('click', resetFocus);

  /* settings */
  $$('.set-row[data-mode]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state = { ...state, theme: btn.dataset.mode };
      saveState();
      applyTheme();
    });
  });
  $('#btn-accent').addEventListener('click', () => {
    renderAccentGrid();
    openSheet('sheet-accent');
  });
  $('#accent-grid').addEventListener('click', (e) => {
    const dot = e.target.closest('[data-accent]');
    if (!dot) return;
    state = { ...state, accent: dot.dataset.accent };
    saveState();
    applyAccent();
    closeSheet();
    toast(`Warna aksen: ${dot.dataset.accent.toUpperCase()}`);
  });
  $('#btn-sticker').addEventListener('click', openStickerSheet);
  $('#sticker-text').addEventListener('input', (e) => {
    stickerDraft = e.target.value;
    $('#sticker-preview-box').textContent = stickerDraft || '✨';
    renderStickerGrid();
  });
  $('#sticker-grid').addEventListener('click', (e) => {
    const item = e.target.closest('[data-sticker]');
    if (!item) return;
    stickerDraft = item.dataset.sticker;
    $('#sticker-text').value = '';
    $('#sticker-preview-box').textContent = stickerDraft;
    renderStickerGrid();
  });
  $('#sticker-none').addEventListener('click', () => {
    stickerDraft = '';
    $('#sticker-text').value = '';
    $('#sticker-preview-box').textContent = '🚫';
    renderStickerGrid();
  });
  $('#sticker-save').addEventListener('click', () => {
    state = { ...state, sticker: stickerDraft };
    saveState();
    renderSettings();
    closeSheet();
    toast('Stiker widget disimpan');
  });
  $$('.set-row[data-toast]').forEach((btn) => {
    btn.addEventListener('click', () => toast(btn.dataset.toast));
  });
  $('#btn-muat-contoh').addEventListener('click', () => {
    if (state.tasks.some((t) => t.example)) {
      toast('Contoh data sudah ada');
      return;
    }
    const seed = makeSeedState(new Date());
    state = {
      ...state,
      tasks: [...state.tasks, ...seed.tasks],
      notes: [...state.notes, ...seed.notes],
      habits: [...state.habits, ...seed.habits],
    };
    saveState();
    renderAll();
    toast('Contoh data dimuat');
  });
  $('#btn-hapus-contoh').addEventListener('click', () => {
    state = {
      ...state,
      tasks: state.tasks.filter((t) => !t.example),
      notes: state.notes.filter((n) => !n.example),
      habits: state.habits.filter((h) => !h.example),
    };
    saveState();
    renderAll();
    toast('Contoh data dihapus');
  });
  $('#btn-hapus-data').addEventListener('click', () => {
    if (!window.confirm('Hapus semua data?')) return;
    state = { ...state, tasks: [], notes: [], habits: [] };
    saveState();
    renderAll();
    toast('Semua data dihapus');
  });
  $('#btn-ulangi-tour').addEventListener('click', showTour);

  /* reset demo (panel) */
  $('#btn-reset-panel').addEventListener('click', () => {
    try {
      localStorage.removeItem(LS_KEY);
    } catch (_) { /* ignore */ }
    state = migrateState(makeSeedState(new Date()));
    searchQ = '';
    noteSearchQ = null;
    const box = $('#notes-search-box');
    if (box) box.remove();
    currentTab = 'home';
    selectedDayKey = null;
    calendarCursor = null;
    focusRemaining = 25 * 60;
    if (focusInterval) { clearInterval(focusInterval); focusInterval = null; }
    applyTheme();
    applyAccent();
    renderAll();
    closeSheet();
    toast('Data demo direset');
  });
}

/* ---------- splash / tour ---------- */

let splashMarkup = null;

function showTour() {
  if ($('#splash')) return;
  const wrapper = document.createElement('div');
  wrapper.innerHTML = splashMarkup.trim();
  const node = wrapper.firstElementChild;
  $('#app').prepend(node);
  setTimeout(() => node.classList.add('done'), 900);
  setTimeout(() => node.remove(), 1500);
}

/* ---------- init ---------- */

function init() {
  const raw = loadState();
  state = raw ? migrateState(raw) : makeSeedState(new Date());

  selectedDayKey = dateKey(new Date());
  calendarCursor = parseKey(selectedDayKey);
  focusRemaining = 25 * 60;

  initRingGradient('hero-grad', $('#hero-ring'));
  initRingGradient('dash-grad', $('#dash-ring'));

  applyTheme();
  applyAccent();
  renderAll();
  bindEvents();

  /* splash */
  const splash = $('#splash');
  splashMarkup = splash.outerHTML;
  setTimeout(() => splash.classList.add('done'), 900);
  setTimeout(() => { splash.remove(); }, 1500);
}

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  document.addEventListener('DOMContentLoaded', init);
}

/* export untuk smoke test Node */
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
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
    categoryOf,
    CATEGORIES,
    LABELS,
    TEMPLATES,
    PRIORITY,
    uid,
  };
}
