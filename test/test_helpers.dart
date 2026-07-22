import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:todoaw/data/database.dart';
import 'package:todoaw/data/models/category.dart';
import 'package:todoaw/data/models/task.dart';

void setupTestDatabase() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> initTestDb() async {
  await AppDatabase.init(dbName: inMemoryDatabasePath);
}

Future<void> closeTestDb() async {
  await AppDatabase.instance.close();
}

Future<Task> createTestTask({
  String? uuid,
  String title = 'Test Task',
  String? description,
  bool isCompleted = false,
  Priority priority = Priority.p3,
  String? categoryId,
  DateTime? dueDate,
}) async {
  final now = DateTime.now();
  final task = Task(
    uuid: uuid ?? const Uuid().v4(),
    title: title,
    description: description,
    isCompleted: isCompleted,
    priority: priority,
    categoryId: categoryId,
    dueDate: dueDate,
    createdAt: now,
    updatedAt: now,
  );
  await AppDatabase.insertTask(task);
  return task;
}

Future<Category> createTestCategory({
  String? uuid,
  String name = 'Test Category',
  int color = 0xFF5B67CA,
}) async {
  final category = Category(
    uuid: uuid ?? const Uuid().v4(),
    name: name,
    color: color,
  );
  await AppDatabase.insertCategory(category);
  return category;
}
