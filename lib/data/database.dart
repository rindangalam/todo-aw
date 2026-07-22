import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart' as p;

import 'models/category.dart';
import 'models/focus_session.dart';
import 'models/habit.dart';
import 'models/habit_log.dart';
import 'models/note.dart';
import 'models/task.dart';

class AppDatabase {
  static late sqlite.Database instance;

  static Future<void> init({String? dbName}) async {
    final fullPath =
        dbName ?? p.join(await sqlite.getDatabasesPath(), 'todoaw.db');
    instance = await sqlite.openDatabase(
      fullPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            uuid TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            priority INTEGER NOT NULL DEFAULT 2,
            categoryId TEXT,
            dueDate TEXT,
            isRecurring INTEGER NOT NULL DEFAULT 0,
            recurringRule TEXT,
            parentId TEXT,
            isArchived INTEGER NOT NULL DEFAULT 0,
            deletedAt TEXT,
            reminderMinutes INTEGER,
            estimatedMinutes INTEGER,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_tasks_created ON tasks(createdAt)
        ''');
        await db.execute('''
          CREATE INDEX idx_tasks_due ON tasks(dueDate)
        ''');
        await db.execute('''
          CREATE TABLE categories (
            uuid TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            color INTEGER NOT NULL DEFAULT 4280100298,
            icon TEXT,
            sortOrder INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE habits (
            uuid TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            color INTEGER NOT NULL DEFAULT 4279895538,
            icon TEXT,
            frequency INTEGER NOT NULL DEFAULT 0,
            targetCount INTEGER NOT NULL DEFAULT 1,
            currentStreak INTEGER NOT NULL DEFAULT 0,
            longestStreak INTEGER NOT NULL DEFAULT 0,
            sortOrder INTEGER NOT NULL DEFAULT 0,
            isArchived INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_logs (
            uuid TEXT PRIMARY KEY,
            habitId TEXT NOT NULL,
            date TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 1,
            note TEXT,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (habitId) REFERENCES habits(uuid)
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_habit_logs_habit ON habit_logs(habitId)
        ''');
        await db.execute('''
          CREATE INDEX idx_habit_logs_date ON habit_logs(date)
        ''');
        await db.execute('''
          CREATE TABLE notes (
            uuid TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT,
            color INTEGER NOT NULL DEFAULT 4294955658,
            isPinned INTEGER NOT NULL DEFAULT 0,
            isArchived INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE focus_sessions (
            uuid TEXT PRIMARY KEY,
            taskId TEXT,
            durationMinutes INTEGER NOT NULL DEFAULT 25,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            startedAt TEXT,
            endedAt TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_focus_sessions_task ON focus_sessions(taskId)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN reminderMinutes INTEGER');
          await db.execute('ALTER TABLE tasks ADD COLUMN estimatedMinutes INTEGER');
          await db.execute('''
            CREATE TABLE habits (
              uuid TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              color INTEGER NOT NULL DEFAULT 4279895538,
              icon TEXT,
              frequency INTEGER NOT NULL DEFAULT 0,
              targetCount INTEGER NOT NULL DEFAULT 1,
              currentStreak INTEGER NOT NULL DEFAULT 0,
              longestStreak INTEGER NOT NULL DEFAULT 0,
              sortOrder INTEGER NOT NULL DEFAULT 0,
              isArchived INTEGER NOT NULL DEFAULT 0,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE habit_logs (
              uuid TEXT PRIMARY KEY,
              habitId TEXT NOT NULL,
              date TEXT NOT NULL,
              isCompleted INTEGER NOT NULL DEFAULT 1,
              note TEXT,
              createdAt TEXT NOT NULL,
              FOREIGN KEY (habitId) REFERENCES habits(uuid)
            )
          ''');
          await db.execute('''
            CREATE INDEX idx_habit_logs_habit ON habit_logs(habitId)
          ''');
          await db.execute('''
            CREATE INDEX idx_habit_logs_date ON habit_logs(date)
          ''');
          await db.execute('''
            CREATE TABLE notes (
              uuid TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT,
              color INTEGER NOT NULL DEFAULT 4294955658,
              isPinned INTEGER NOT NULL DEFAULT 0,
              isArchived INTEGER NOT NULL DEFAULT 0,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE focus_sessions (
              uuid TEXT PRIMARY KEY,
              taskId TEXT,
              durationMinutes INTEGER NOT NULL DEFAULT 25,
              isCompleted INTEGER NOT NULL DEFAULT 0,
              startedAt TEXT,
              endedAt TEXT,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE INDEX idx_focus_sessions_task ON focus_sessions(taskId)
          ''');
        }
      },
    );
  }

  static Future<List<Task>> getAllTasks() async {
    final maps = await instance.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  static Future<List<Task>> getActiveTasks() async {
    final maps = await instance.query(
      'tasks',
      where: 'isArchived = ? AND deletedAt IS NULL',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  static Future<Task?> getTask(String uuid) async {
    final maps = await instance.query(
      'tasks',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  static Future<void> insertTask(Task task) async {
    await instance.insert('tasks', task.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
  }

  static Future<void> updateTask(Task task) async {
    await instance.update(
      'tasks',
      task.toMap(),
      where: 'uuid = ?',
      whereArgs: [task.uuid],
    );
  }

  static Future<void> deleteTask(String uuid) async {
    await instance.delete('tasks', where: 'uuid = ?', whereArgs: [uuid]);
  }

  static Future<List<Task>> searchTasks(String query) async {
    final maps = await instance.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  static Future<List<Category>> getAllCategories() async {
    final maps = await instance.query('categories', orderBy: 'sortOrder ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  static Future<Category?> getCategory(String uuid) async {
    final maps = await instance.query(
      'categories',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  static Future<void> insertCategory(Category category) async {
    await instance.insert('categories', category.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
  }

  static Future<void> updateCategory(Category category) async {
    await instance.update(
      'categories',
      category.toMap(),
      where: 'uuid = ?',
      whereArgs: [category.uuid],
    );
  }

  static Future<void> deleteCategory(String uuid) async {
    await instance.delete(
      'categories',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  static Future<List<Habit>> getAllHabits() async {
    final maps = await instance.query('habits', orderBy: 'sortOrder ASC');
    return maps.map((m) => Habit.fromMap(m)).toList();
  }

  static Future<Habit?> getHabit(String uuid) async {
    final maps = await instance.query(
      'habits',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  static Future<void> insertHabit(Habit habit) async {
    await instance.insert('habits', habit.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
  }

  static Future<void> updateHabit(Habit habit) async {
    await instance.update(
      'habits',
      habit.toMap(),
      where: 'uuid = ?',
      whereArgs: [habit.uuid],
    );
  }

  static Future<void> deleteHabit(String uuid) async {
    await instance.delete('habits', where: 'uuid = ?', whereArgs: [uuid]);
  }

  static Future<List<HabitLog>> getHabitLogs(String habitId) async {
    final maps = await instance.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  static Future<List<HabitLog>> getHabitLogsByDate(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    final maps = await instance.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [day.toIso8601String()],
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  static Future<HabitLog?> getHabitLog(String habitId, DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    final maps = await instance.query(
      'habit_logs',
      where: 'habitId = ? AND date = ?',
      whereArgs: [habitId, day.toIso8601String()],
    );
    if (maps.isEmpty) return null;
    return HabitLog.fromMap(maps.first);
  }

  static Future<void> insertHabitLog(HabitLog log) async {
    await instance.insert('habit_logs', log.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
  }

  static Future<void> deleteHabitLog(String uuid) async {
    await instance.delete('habit_logs', where: 'uuid = ?', whereArgs: [uuid]);
  }

  static Future<List<Note>> getAllNotes() async {
    final maps = await instance.query(
      'notes',
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  static Future<Note?> getNote(String uuid) async {
    final maps = await instance.query(
      'notes',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  static Future<void> insertNote(Note note) async {
    await instance.insert('notes', note.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
  }

  static Future<void> updateNote(Note note) async {
    await instance.update(
      'notes',
      note.toMap(),
      where: 'uuid = ?',
      whereArgs: [note.uuid],
    );
  }

  static Future<List<Note>> searchNotes(String query) async {
    final maps = await instance.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  static Future<void> deleteNote(String uuid) async {
    await instance.delete('notes', where: 'uuid = ?', whereArgs: [uuid]);
  }

  static Future<List<FocusSession>> getFocusSessions() async {
    final maps = await instance.query('focus_sessions', orderBy: 'createdAt DESC');
    return maps.map((m) => FocusSession.fromMap(m)).toList();
  }

  static Future<List<FocusSession>> getFocusSessionsByTask(String taskId) async {
    final maps = await instance.query(
      'focus_sessions',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => FocusSession.fromMap(m)).toList();
  }

  static Future<void> insertFocusSession(FocusSession session) async {
    await instance.insert('focus_sessions', session.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
  }

  static Future<void> updateFocusSession(FocusSession session) async {
    await instance.update(
      'focus_sessions',
      session.toMap(),
      where: 'uuid = ?',
      whereArgs: [session.uuid],
    );
  }

  static Future<void> deleteFocusSession(String uuid) async {
    await instance.delete('focus_sessions', where: 'uuid = ?', whereArgs: [uuid]);
  }
}
