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

const CATEGORIES = [
  { id: 'none', name: 'Tanpa Kategori', color: null },
  { id: 'kerja', name: 'Pekerjaan', color: '#3B82F6' },
  { id: 'rumah', name: 'Rumah', color: '#F59E0B' },
  { id: 'belajar', name: 'Belajar', color: '#8B5CF6' },
];

const TEMPLATES = [
  { title: 'Rutin Pagi', desc: 'Olahraga ringan, sarapan, cek jadwal' },
  { title: 'Belanja Mingguan', desc: 'Buat daftar belanja minggu ini' },
  { title: 'Review Mingguan', desc: 'Evaluasi progres minggu ini' },
  { title: 'Sprint Backlog', desc: 'Rinci task untuk sprint berikutnya' },
];

function makeSeedState(now) {
  const today = dateKey(now);
  const tomorrow = addDays(today, 1);
  const dayAfter = addDays(today, 2);
  const yesterday = addDays(today, -1);
  const twoDaysAgo = addDays(today, -2);

  const tasks = [
    { id: uid(), title: 'Beli bahan masakan', desc: 'Sayur, telur, dan bumbu dapur', priority: 'p1', categoryId: 'rumah', dueDate: tomorrow, isCompleted: false, tags: ['#F59E0B'] },
    { id: uid(), title: 'Selesaikan laporan proyek', desc: 'Bab 3-5, lengkapi grafik dan kesimpulan', priority: 'p4', categoryId: 'kerja', dueDate: today, isCompleted: false, tags: ['#EF4444'] },
    { id: uid(), title: 'Design mockup halaman login', desc: 'Buat 3 varian di Figma', priority: 'p3', categoryId: 'kerja', dueDate: dayAfter, isCompleted: false, tags: ['#8B5CF6'] },
    { id: uid(), title: 'Refactor API endpoint', desc: 'Pisahkan controller dan service layer', priority: 'p4', categoryId: 'kerja', dueDate: null, isCompleted: false, tags: ['#10B981'] },
    { id: uid(), title: 'Olahraga sore', desc: 'Jogging 30 menit di taman', priority: 'p1', categoryId: 'none', dueDate: today, isCompleted: true, tags: [] },
    { id: uid(), title: 'Baca artikel Flutter Riverpod', desc: 'https://docs-v2.riverpod.dev', priority: 'p1', categoryId: 'belajar', dueDate: null, isCompleted: false, tags: ['#EF4444'] },
    { id: uid(), title: 'Ganti password wifi', desc: 'Buat password baru dan update di semua device', priority: 'p2', categoryId: 'rumah', dueDate: tomorrow, isCompleted: false, tags: ['#F59E0B'] },
    { id: uid(), title: 'Meeting tim', desc: '20 menit, bahas sprint review', priority: 'p2', categoryId: 'kerja', dueDate: today, isCompleted: false, tags: [] },
    { id: uid(), title: 'Jogging pagi', desc: '5 km di sekitar kompleks', priority: 'p3', categoryId: 'none', dueDate: yesterday, isCompleted: true, tags: [] },
    { id: uid(), title: 'Baca 10 halaman buku', desc: 'Lanjut bab 4', priority: 'p4', categoryId: 'belajar', dueDate: twoDaysAgo, isCompleted: true, tags: [] },
  ];

  const notes = [
    { id: uid(), title: 'Ide aplikasi', body: 'Integrasi widget home screen untuk quick add task', createdAt: today },
    { id: uid(), title: 'Grocery list', body: 'Telur, susu, kopi, sayur, dan sabun cuci piring', createdAt: yesterday },
    { id: uid(), title: 'Belajar Flutter', body: 'Riverpod: provider vs notifier, AsyncValue states', createdAt: twoDaysAgo },
  ];

  return {
    tasks,
    notes,
    habits: [],
    theme: 'light',
    accent: '#0EA5E9',
    sticker: 'Tanpa',
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

function categoryOf(task) {
  return CATEGORIES.find((c) => c.id === task.categoryId) || CATEGORIES[0];
}

function hexToRgba(hex, alpha) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

/* ---------------- UI layer (browser) ---------------- */

const LS_KEY = 'todoaw-demo-v1';
const RING_CIRC = 188.5;
const FOCUS_CIRC = 339.3;
const STICKERS = ['Tanpa', '🚀', '💪', '🔥', '😎', '✨'];

let state = null;
let currentTab = 'home';
let selectedDayKey = null;
let calendarCursor = null;
let focusRemaining = 0;
let focusInterval = null;
let toastTimer = null;

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

function saveState() {
  try {
    localStorage.setItem(LS_KEY, JSON.stringify(state));
  } catch (_) {
    /* localStorage tidak tersedia (mis. file:// strict) — abaikan */
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

function applyTheme() {
  const app = $('#app');
  app.dataset.theme = state.theme;
  document.body.classList.toggle('dark', state.theme === 'dark');
  $('#theme-switch').checked = state.theme === 'dark';
}

function applyAccent() {
  const app = $('#app');
  app.style.setProperty('--accent', state.accent);
  app.style.setProperty('--accent-soft', hexToRgba(state.accent, 0.12));
  renderAccentRow();
}

/* ---------- task card HTML ---------- */

function priorityBadgeHTML(priority) {
  const p = PRIORITY[priority] || PRIORITY.p4;
  return `<span class="tc-priority ${priority}" style="color:${p.color};background:${hexToRgba(p.color, 0.14)}">${p.label}</span>`;
}

function taskCardHTML(task, todayKey) {
  const cat = categoryOf(task);
  const dotColor = cat.color ? `style="background:${cat.color}"` : `style="background:var(--muted);opacity:.4"`;
  const tagDots = (task.tags || [])
    .map((c) => `<span style="background:${c}"></span>`)
    .join('');
  const meta = [];
  if (task.dueDate) {
    meta.push(`<svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 11h-2V8h2v5zm-1 6a6 6 0 1 1 0-12 6 6 0 0 1 0 12z"/></svg>`);
    meta.push(`<span>${formatDateLabel(task.dueDate, todayKey)}</span>`);
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

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/* ---------- renderers ---------- */

function renderAll() {
  renderHome();
  renderCalendar();
  renderDashboard();
  renderNotes();
  updateNav();
  updateFab();
}

function renderHome() {
  const todayKey = dateKey(new Date());
  const { total, completed, percent } = computeTodayProgress(state.tasks, todayKey);
  const stats = computeStats(state.tasks, todayKey);
  const accent = percent >= 1 && total > 0 ? '#10B981' : state.accent;

  $('#hero-ring').style.strokeDashoffset = RING_CIRC * (1 - percent);
  $('#hero-ring').style.stroke = accent;
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

  const list = sortTasks(state.tasks);
  const listEl = $('#task-list');
  const emptyEl = $('#empty-state');
  if (list.length === 0) {
    listEl.innerHTML = '';
    emptyEl.hidden = false;
    $('#empty-title').textContent = 'Hari ini santai?';
    $('#empty-sub').textContent = 'Yuk, bikin tugas pertama';
  } else {
    listEl.innerHTML = list.map((t) => taskCardHTML(t, todayKey)).join('');
    emptyEl.hidden = true;
  }
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

  const taskKeys = new Set(state.tasks.filter((t) => t.dueDate).map((t) => t.dueDate));
  const cells = [];

  const prevDays = new Date(cursor.getFullYear(), cursor.getMonth(), 0).getDate();
  for (let i = offset - 1; i >= 0; i--) {
    const day = prevDays - i;
    const d = new Date(cursor.getFullYear(), cursor.getMonth() - 1, day);
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
  renderDayTasks();
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

function renderDayTasks() {
  const todayKey = dateKey(new Date());
  const key = selectedDayKey || todayKey;
  $('#cal-day-title').textContent =
    key === todayKey ? 'Tugas Hari Ini' : `Tugas — ${formatDateLabel(key, todayKey)}`;

  const tasks = state.tasks.filter((t) => t.dueDate === key);
  const listEl = $('#cal-day-tasks');
  const emptyEl = $('#cal-empty');
  if (tasks.length === 0) {
    listEl.innerHTML = '';
    emptyEl.hidden = false;
  } else {
    listEl.innerHTML = sortTasks(tasks).map((t) => taskCardHTML(t, todayKey)).join('');
    emptyEl.hidden = true;
  }
}

function renderDashboard() {
  const todayKey = dateKey(new Date());
  const { total, completed, percent } = computeTodayProgress(state.tasks, todayKey);
  const stats = computeStats(state.tasks, todayKey);
  const accent = percent >= 1 && total > 0 ? '#10B981' : state.accent;

  $('#dash-ring').style.strokeDashoffset = RING_CIRC * (1 - percent);
  $('#dash-ring').style.stroke = accent;
  $('#dash-pct').textContent = `${Math.round(percent * 100)}%`;
  $('#dash-count').textContent = `${completed}/${total} tugas hari ini`;
  const bar = $('#dash-bar');
  bar.style.width = `${Math.round(percent * 100)}%`;
  bar.style.background = accent;

  const counts = weeklyCounts(state.tasks, mondayKeyOf(todayKey));
  const max = Math.max(...counts, 1);
  $('#week-chart').innerHTML = counts
    .map((c, i) => {
      const h = c > 0 ? 18 + Math.round((c / max) * 58) : 6;
      return `
        <div class="wc-col">
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
  const listEl = $('#notes-list');
  const emptyEl = $('#notes-empty');
  if (state.notes.length === 0) {
    listEl.innerHTML = '';
    emptyEl.hidden = false;
    return;
  }
  emptyEl.hidden = true;
  listEl.innerHTML = state.notes
    .map(
      (n) => `
      <div class="note-card" data-id="${n.id}">
        <div class="note-title">${escapeHtml(n.title)}</div>
        <div class="note-body">${escapeHtml(n.body)}</div>
        <div class="note-date">${formatDateLabel(n.createdAt, dateKey(new Date()))}</div>
      </div>`
    )
    .join('');
}

function renderHabits() {
  const listEl = $('#habit-list');
  const emptyEl = $('#habit-empty');
  if (state.habits.length === 0) {
    listEl.innerHTML = '';
    emptyEl.hidden = false;
    return;
  }
  emptyEl.hidden = true;
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

function renderAccentRow() {
  const colors = ['#0EA5E9', '#8B5CF6', '#10B981', '#F59E0B'];
  $('#accent-row').innerHTML = colors
    .map(
      (c) =>
        `<button class="accent-dot ${c === state.accent ? 'sel' : ''}" data-accent="${c}" style="background:${c}"></button>`
    )
    .join('');

  $('#sticker-row').innerHTML = STICKERS.map(
    (s) =>
      `<button class="sticker-chip ${s === state.sticker ? 'sel' : ''}" data-sticker="${s}">${s}</button>`
  ).join('');
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

let editingTaskId = null;

function renderCategoryChips() {
  $('#tf-category').innerHTML = CATEGORIES.map(
    (c) => `<button class="chip cat-chip" data-cat="${c.id}">${c.name}</button>`
  ).join('');
}

function renderPriorityChips(selected) {
  $$('#tf-priority .chip').forEach((chip) => {
    chip.classList.toggle('sel', chip.dataset.priority === selected);
  });
}

function openTaskSheet(task) {
  editingTaskId = task ? task.id : null;
  $('#sheet-task-title').textContent = task ? 'Edit Tugas' : 'Tambah Tugas';
  $('#tf-title').value = task ? task.title : '';
  $('#tf-desc').value = task ? task.desc : '';
  $('#tf-date').value = task && task.dueDate ? task.dueDate : '';
  $('#tf-delete').hidden = !task;
  renderPriorityChips(task ? task.priority : 'p2');
  renderCategoryChips();
  $$('#tf-category .chip').forEach((chip) => {
    chip.classList.toggle('sel', (task ? task.categoryId : 'none') === chip.dataset.cat);
  });
  openSheet('sheet-task');
}

function saveTaskFromForm() {
  const title = $('#tf-title').value.trim();
  if (!title) {
    toast('Judul wajib diisi');
    return;
  }
  const priority = $('#tf-priority .chip.sel')?.dataset.priority || 'p2';
  const categoryId = $('#tf-category .chip.sel')?.dataset.cat || 'none';
  const dueDate = $('#tf-date').value || null;

  if (editingTaskId) {
    state = {
      ...state,
      tasks: state.tasks.map((t) =>
        t.id === editingTaskId
          ? { ...t, title, desc: $('#tf-desc').value.trim(), priority, categoryId, dueDate }
          : t
      ),
    };
  } else {
    state = addTask(state, {
      id: uid(),
      title,
      desc: $('#tf-desc').value.trim(),
      priority,
      categoryId,
      dueDate,
      isCompleted: false,
      tags: [],
    });
  }
  saveState();
  closeSheet();
  renderAll();
}

/* ---------- template picker ---------- */

function renderTemplates() {
  $('#template-list').innerHTML = TEMPLATES.map(
    (t) => `
      <div class="tpl-item" data-title="${t.title}">
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

let editingNoteId = null;

function openNoteSheet(note) {
  editingNoteId = note ? note.id : null;
  $('#sheet-note-title').textContent = note ? 'Edit Catatan' : 'Tambah Catatan';
  $('#nf-title').value = note ? note.title : '';
  $('#nf-body').value = note ? note.body : '';
  $('#nf-delete').hidden = !note;
  openSheet('sheet-note');
}

function saveNoteFromForm() {
  const title = $('#nf-title').value.trim();
  if (!title) {
    toast('Judul catatan wajib diisi');
    return;
  }
  const body = $('#nf-body').value.trim();
  if (editingNoteId) {
    state = {
      ...state,
      notes: state.notes.map((n) =>
        n.id === editingNoteId ? { ...n, title, body } : n
      ),
    };
  } else {
    state = addNote(state, { id: uid(), title, body, createdAt: dateKey(new Date()) });
  }
  saveState();
  closeSheet();
  renderNotes();
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

/* ---------- interactions ---------- */

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

  /* demo-only buttons */
  $('#btn-search').addEventListener('click', () => toast('Pencarian hanya ada di app asli'));
  $('#btn-filter').addEventListener('click', () => toast('Filter hanya ada di app asli'));

  /* task list interactions (delegated) */
  const taskLists = ['#task-list', '#cal-day-tasks', '#day-tasks'];
  taskLists.forEach((sel) => {
    document.querySelector(sel).addEventListener('click', (e) => {
      const toggleBtn = e.target.closest('[data-act="toggle"]');
      const delBtn = e.target.closest('[data-act="delete"]');
      const card = e.target.closest('.task-card');
      if (!card) return;
      if (toggleBtn) {
        state = toggleTask(state, card.dataset.id);
      } else if (delBtn) {
        state = deleteTask(state, card.dataset.id);
      } else {
        const task = state.tasks.find((t) => t.id === card.dataset.id);
        if (task) openTaskSheet(task);
        return;
      }
      saveState();
      renderAll();
    });
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
  $('#btn-cal-today').addEventListener('click', () => {
    calendarCursor = parseKey(dateKey(new Date()));
    selectedDayKey = dateKey(new Date());
    renderCalendar();
  });
  $('#cal-grid').addEventListener('click', (e) => {
    const cell = e.target.closest('[data-day]');
    if (!cell) return;
    selectedDayKey = cell.dataset.day;
    renderCalendar();
  });

  /* sheet backdrop */
  $('#sheet-backdrop').addEventListener('click', (e) => {
    if (e.target.id === 'sheet-backdrop') closeSheet();
  });

  /* task form */
  $('#tf-priority').addEventListener('click', (e) => {
    const chip = e.target.closest('[data-priority]');
    if (chip) renderPriorityChips(chip.dataset.priority);
  });
  $('#tf-category').addEventListener('click', (e) => {
    const chip = e.target.closest('[data-cat]');
    if (!chip) return;
    $$('#tf-category .chip').forEach((c) => c.classList.toggle('sel', c === chip));
  });
  $('#tf-save').addEventListener('click', saveTaskFromForm);
  $('#tf-delete').addEventListener('click', () => {
    if (!editingTaskId) return;
    state = deleteTask(state, editingTaskId);
    saveState();
    closeSheet();
    renderAll();
  });
  $('#tf-title').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') saveTaskFromForm();
  });

  /* template picker */
  $('#template-list').addEventListener('click', (e) => {
    const item = e.target.closest('.tpl-item');
    if (!item) return;
    state = addTask(state, {
      id: uid(),
      title: item.dataset.title,
      desc: '',
      priority: 'p2',
      categoryId: 'none',
      dueDate: null,
      isCompleted: false,
      tags: [],
    });
    saveState();
    closeSheet();
    renderAll();
    toast(`Template ditambahkan: ${item.dataset.title}`);
  });

  /* notes */
  $('#notes-list').addEventListener('click', (e) => {
    const card = e.target.closest('.note-card');
    if (!card) return;
    const note = state.notes.find((n) => n.id === card.dataset.id);
    if (note) openNoteSheet(note);
  });
  $('#nf-save').addEventListener('click', saveNoteFromForm);
  $('#nf-delete').addEventListener('click', () => {
    if (!editingNoteId) return;
    state = deleteNote(state, editingNoteId);
    saveState();
    closeSheet();
    renderNotes();
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
  $('#theme-switch').addEventListener('change', (e) => {
    state = { ...state, theme: e.target.checked ? 'dark' : 'light' };
    saveState();
    applyTheme();
  });
  $('#accent-row').addEventListener('click', (e) => {
    const dot = e.target.closest('[data-accent]');
    if (!dot) return;
    state = { ...state, accent: dot.dataset.accent };
    saveState();
    applyAccent();
    renderAll();
  });
  $('#sticker-row').addEventListener('click', (e) => {
    const chip = e.target.closest('[data-sticker]');
    if (!chip) return;
    state = { ...state, sticker: chip.dataset.sticker };
    saveState();
    renderAccentRow();
    toast(`Stiker widget: ${chip.dataset.sticker}`);
  });
  $$('.set-row[data-toast]').forEach((btn) => {
    btn.addEventListener('click', () => toast(btn.dataset.toast));
  });

  /* reset demo */
  const resetDemo = () => {
    try {
      localStorage.removeItem(LS_KEY);
    } catch (_) { /* ignore */ }
    state = makeSeedState(new Date());
    saveState();
    currentTab = 'home';
    selectedDayKey = null;
    calendarCursor = null;
    focusRemaining = 25 * 60;
    if (focusInterval) { clearInterval(focusInterval); focusInterval = null; }
    applyTheme();
    applyAccent();
    setTab('home');
    renderAll();
    closeSheet();
    toast('Data demo direset');
  };
  $('#btn-reset-demo').addEventListener('click', resetDemo);
  $('#btn-reset-panel').addEventListener('click', resetDemo);
}

/* ---------- init ---------- */

function init() {
  state = loadState() || makeSeedState(new Date());

  selectedDayKey = dateKey(new Date());
  calendarCursor = parseKey(selectedDayKey);
  focusRemaining = 25 * 60;

  applyTheme();
  applyAccent();
  renderAll();
  bindEvents();

  /* splash */
  const splash = $('#splash');
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
    dateKey,
    addDays,
    sortTasks,
    todayTasks,
    CATEGORIES,
    TEMPLATES,
    PRIORITY,
    uid,
  };
}
