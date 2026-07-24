import 'package:uuid/uuid.dart';

import '../data/database.dart';
import '../data/models/category.dart';
import '../data/models/habit.dart';
import '../data/models/habit_log.dart';
import '../data/models/note.dart';
import '../data/models/task.dart';
import '../data/repositories/tag_repository.dart';

final _uuid = const Uuid();
final _tagRepo = TagRepository();

Future<void> seedIfEmpty() async {
  try {
    final tasks = await AppDatabase.getActiveTasks();
    if (tasks.isNotEmpty) return;
  } catch (_) {
    return;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final dayAfter = today.add(const Duration(days: 2));

  // ── Category ──
  final categoryId = _uuid.v4();
  await AppDatabase.insertCategory(Category(
    uuid: categoryId,
    name: 'Pekerjaan',
    color: 0xFF3B82F6,
    icon: 'work',
    sortOrder: 0,
  ));

  // ── Tags ──
  final tagPrioritas =
      await _tagRepo.create(name: 'prioritas', color: 0xFFEF4444);
  final tagDesain = await _tagRepo.create(name: 'desain', color: 0xFF8B5CF6);
  final tagBackend = await _tagRepo.create(name: 'backend', color: 0xFF10B981);
  final tagRumah = await _tagRepo.create(name: 'rumah', color: 0xFFF59E0B);
  final tagBelajar = await _tagRepo.create(name: 'belajar', color: 0xFF6366F1);

  // ── Tasks ──
  final task1Id = _uuid.v4();
  final task2Id = _uuid.v4();
  final task3Id = _uuid.v4();
  final task4Id = _uuid.v4();
  final task5Id = _uuid.v4();
  final task6Id = _uuid.v4();
  final task7Id = _uuid.v4();
  final task8Id = _uuid.v4();

  await AppDatabase.insertTask(Task(
    uuid: task1Id,
    title: 'Beli bahan masakan',
    description: 'Sayur, telur, dan bumbu dapur',
    priority: Priority.p1,
    dueDate: tomorrow,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task2Id,
    title: 'Selesaikan laporan proyek',
    description: 'Bab 3-5, lengkapi grafik dan kesimpulan',
    priority: Priority.p4,
    dueDate: today,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task3Id,
    title: 'Design mockup halaman login',
    description: 'Buat 3 varian di Figma',
    priority: Priority.p3,
    dueDate: dayAfter,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task4Id,
    title: 'Refactor API endpoint',
    description: 'Pisahkan controller dan service layer',
    priority: Priority.p4,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task5Id,
    title: 'Olahraga sore',
    description: 'Jogging 30 menit di taman',
    priority: Priority.p1,
    dueDate: today,
    isCompleted: true,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task6Id,
    title: 'Baca artikel Flutter Riverpod',
    description: 'https://docs-v2.riverpod.dev',
    priority: Priority.p1,
    categoryId: categoryId,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task7Id,
    title: 'Ganti password wifi',
    description: 'Buat password baru dan update di semua device',
    priority: Priority.p2,
    dueDate: tomorrow,
    createdAt: now,
    updatedAt: now,
  ));

  await AppDatabase.insertTask(Task(
    uuid: task8Id,
    title: 'Meeting tim',
    description: '20 menit, bahas sprint review',
    priority: Priority.p4,
    dueDate: today,
    estimatedMinutes: 20,
    createdAt: now,
    updatedAt: now,
  ));

  // ── Task-Tag relations ──
  await AppDatabase.setTaskTags(task1Id, [tagRumah.uuid]);
  await AppDatabase.setTaskTags(task2Id, [tagPrioritas.uuid, tagDesain.uuid]);
  await AppDatabase.setTaskTags(task3Id, [tagDesain.uuid]);
  await AppDatabase.setTaskTags(task4Id, [tagBackend.uuid, tagPrioritas.uuid]);
  await AppDatabase.setTaskTags(task6Id, [tagBelajar.uuid]);
  await AppDatabase.setTaskTags(task7Id, [tagRumah.uuid]);
  await AppDatabase.setTaskTags(task8Id, [tagPrioritas.uuid]);

  // ── Notes ──
  await AppDatabase.insertNote(Note(
    uuid: _uuid.v4(),
    title: 'Ide fitur baru',
    content:
        'Mode gelap otomatis berdasarkan jadwal\nIntegrasi Google Calendar\nEkspor data ke CSV',
    color: 0xFFFDE68A,
    createdAt: now.subtract(const Duration(hours: 3)),
    updatedAt: now,
  ));
  await AppDatabase.insertNote(Note(
    uuid: _uuid.v4(),
    title: 'Catatan meeting',
    content:
        'Hadir: Tim developer (5 orang)\nAgenda:\n- Review sprint sebelumnya\n- Planning sprint berikutnya\n- Diskusi teknis migrasi database',
    color: 0xFFA7F3D0,
    createdAt: now.subtract(const Duration(hours: 6)),
    updatedAt: now,
  ));
  await AppDatabase.insertNote(Note(
    uuid: _uuid.v4(),
    title: 'Resep masakan',
    content:
        'Nasi goreng spesial:\n- Nasi putih 2 piring\n- Telur 2 butir\n- Ayam suwir\n- Kecap manis & saus sambal\n- Bawang merah, bawang putih, daun bawang',
    color: 0xFFFCA5A5,
    isPinned: true,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now,
  ));

  // ── Habits ──
  final habit1Id = _uuid.v4();
  final habit2Id = _uuid.v4();

  await AppDatabase.insertHabit(Habit(
    uuid: habit1Id,
    name: 'Minum air 8 gelas',
    color: 0xFF3B82F6,
    frequency: HabitFrequency.daily,
    targetCount: 8,
    createdAt: now.subtract(const Duration(days: 14)),
    updatedAt: now,
  ));
  await AppDatabase.insertHabit(Habit(
    uuid: habit2Id,
    name: 'Baca 15 menit',
    color: 0xFF8B5CF6,
    frequency: HabitFrequency.daily,
    targetCount: 1,
    currentStreak: 5,
    longestStreak: 12,
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now,
  ));

  // ── Habit logs (hari ini) ──
  await AppDatabase.insertHabitLog(
    _makeLog(habit1Id, today, 3, now),
  );
  await AppDatabase.insertHabitLog(
    _makeLog(habit2Id, today, 1, now),
  );
}

HabitLog _makeLog(String habitId, DateTime date, int count, DateTime now) {
  return HabitLog(
    uuid: _uuid.v4(),
    habitId: habitId,
    date: date,
    isCompleted: count > 0,
    createdAt: now,
  );
}
