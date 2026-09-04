import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

import '../../data/database.dart';
import '../../data/models/category.dart';
import '../../data/models/focus_session.dart';
import '../../data/models/habit.dart';
import '../../data/models/note.dart';
import '../../data/models/tag.dart';
import '../../data/models/task.dart';

class DataService {
  static const _channel = MethodChannel('com.todoaw.todoaw/savefile');

  String get _timestamp {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$y-$m-${d}_$h-$min-$s';
  }

  Future<String> _saveBytes(Uint8List bytes, String filename) async {
    try {
      return await _channel.invokeMethod('saveToDownloads', {
        'data': bytes,
        'filename': filename,
        'mimeType': 'application/octet-stream',
      });
    } on MissingPluginException {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('Gagal mengakses penyimpanan eksternal');
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  Future<String> exportJson() async {
    final data = await _collectAllData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(json));
    return _saveBytes(bytes, 'todoaw_backup_$_timestamp.json');
  }

  Future<String> exportExcel() async {
    final xl = Excel.createExcel();
    final data = await _collectAllData();

    for (final entry in data.entries) {
      if (entry.key == 'exportedAt' || entry.key == 'version') continue;
      if (entry.value is! List) continue;

      final sheetName = entry.key;
      final rows = entry.value as List;
      if (rows.isEmpty) continue;

      final sheet = xl[sheetName];
      final headers = (rows.first as Map<String, dynamic>).keys.toList();

      for (var col = 0; col < headers.length; col++) {
        sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: 0,
        )).value = TextCellValue(headers[col]);
      }

      for (var r = 0; r < rows.length; r++) {
        final row = rows[r] as Map<String, dynamic>;
        for (var col = 0; col < headers.length; col++) {
          final val = row[headers[col]];
          sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: r + 1,
          )).value = val != null ? TextCellValue(val.toString()) : null;
        }
      }
    }

    final raw = xl.encode();
    if (raw == null) throw Exception('Gagal mengencode Excel');
    return _saveBytes(Uint8List.fromList(raw), 'todoaw_export_$_timestamp.xlsx');
  }

  Future<String> exportSqlite() async {
    final dbPath = await sqlite.getDatabasesPath();
    final source = File('$dbPath/todoaw.db');
    final bytes = await source.readAsBytes();
    return _saveBytes(bytes, 'todoaw_backup_$_timestamp.db');
  }

  Future<Map<String, dynamic>> _collectAllData() async {
    return {
      'tasks': (await AppDatabase.getAllTasks()).map((t) => t.toMap()).toList(),
      'categories':
          (await AppDatabase.getAllCategories()).map((c) => c.toMap()).toList(),
      'tags':
          (await AppDatabase.getAllTags()).map((t) => t.toMap()).toList(),
      'task_tags':
          await AppDatabase.instance.query('task_tags'),
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

  Future<void> importJson(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    await AppDatabase.instance.transaction((txn) async {
      if (data['tasks'] is List) {
        for (final m in data['tasks'] as List) {
          final task = Task.fromMap(m as Map<String, dynamic>);
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
      if (data['tags'] is List) {
        for (final m in data['tags'] as List) {
          final tag = Tag.fromMap(m as Map<String, dynamic>);
          await txn.insert('tags', tag.toMap(),
              conflictAlgorithm: sqlite.ConflictAlgorithm.replace);
        }
      }
      if (data['task_tags'] is List) {
        for (final m in data['task_tags'] as List) {
          await txn.insert('task_tags', m as Map<String, dynamic>,
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
