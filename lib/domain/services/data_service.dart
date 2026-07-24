import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

import '../../data/database.dart';
import '../../data/models/category.dart';
import '../../data/models/focus_session.dart';
import '../../data/models/habit.dart';
import '../../data/models/note.dart';
import '../../data/models/task.dart';
import 'package:path/path.dart' as p;

class DataService {
  Future<String> exportJson() async {
    final data = await _collectAllData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await _getExportDir();
    final file = File(p.join(dir.path, 'todoaw_backup.json'));
    await file.writeAsString(json);
    return file.path;
  }

  Future<String> exportCsv() async {
    final tasks = await AppDatabase.getAllTasks();
    final buffer = StringBuffer();
    buffer.writeln('uuid,title,description,isCompleted,priority,categoryId,'
        'dueDate,isRecurring,recurringRule,parentId,isArchived,deletedAt,'
        'reminderMinutes,estimatedMinutes,createdAt,updatedAt');
    for (final t in tasks) {
      final m = t.toMap();
      buffer.writeln([
        m['uuid'],
        _csvEscape(m['title']),
        _csvEscape(m['description']),
        m['isCompleted'],
        m['priority'],
        m['categoryId'],
        m['dueDate'],
        m['isRecurring'],
        _csvEscape(m['recurringRule']),
        m['parentId'],
        m['isArchived'],
        m['deletedAt'],
        m['reminderMinutes'],
        m['estimatedMinutes'],
        m['createdAt'],
        m['updatedAt'],
      ].join(','));
    }

    final dir = await _getExportDir();
    final file = File(p.join(dir.path, 'todoaw_tasks.csv'));
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String> exportSqlite() async {
    final dbPath = await sqlite.getDatabasesPath();
    final source = File(p.join(dbPath, 'todoaw.db'));
    final dir = await _getExportDir();
    final dest = File(p.join(dir.path, 'todoaw_backup.db'));
    await source.copy(dest.path);
    return dest.path;
  }

  Future<Directory> _getExportDir() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download/Todoaw');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<Map<String, dynamic>> _collectAllData() async {
    return {
      'tasks': (await AppDatabase.getAllTasks()).map((t) => t.toMap()).toList(),
      'categories':
          (await AppDatabase.getAllCategories()).map((c) => c.toMap()).toList(),
      'habits':
          (await AppDatabase.getAllHabits()).map((h) => h.toMap()).toList(),
      'habit_logs':
          await AppDatabase.instance.query('habit_logs', orderBy: 'date DESC'),
      'notes': (await AppDatabase.getAllNotes()).map((n) => n.toMap()).toList(),
      'focus_sessions':
          (await AppDatabase.getFocusSessions()).map((s) => s.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
    };
  }

  String _csvEscape(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  Future<void> importJson(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    await AppDatabase.instance.transaction((txn) async {
      if (data['tasks'] is List) {
        for (final m in data['tasks'] as List) {
          final task = Task.fromMap(m as Map<String, dynamic>);
          // Use existing UUID to allow re-import of same data
          await txn.insert('tasks', task.toMap(),
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
      if (data['categories'] is List) {
        for (final m in data['categories'] as List) {
          final cat = Category.fromMap(m as Map<String, dynamic>);
          await txn.insert('categories', cat.toMap(),
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
      if (data['habits'] is List) {
        for (final m in data['habits'] as List) {
          final habit = Habit.fromMap(m as Map<String, dynamic>);
          await txn.insert('habits', habit.toMap(),
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
      if (data['habit_logs'] is List) {
        for (final m in data['habit_logs'] as List) {
          await txn.insert('habit_logs', m as Map<String, dynamic>,
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
      if (data['notes'] is List) {
        for (final m in data['notes'] as List) {
          final note = Note.fromMap(m as Map<String, dynamic>);
          await txn.insert('notes', note.toMap(),
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
      if (data['focus_sessions'] is List) {
        for (final m in data['focus_sessions'] as List) {
          final session = FocusSession.fromMap(m as Map<String, dynamic>);
          await txn.insert('focus_sessions', session.toMap(),
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
    });
  }
}
