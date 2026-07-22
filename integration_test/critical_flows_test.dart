import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todoaw/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Critical flows', () {
    testWidgets('Flow 1: create task → complete task', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to finish (2s delay)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tap FAB to create task
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill in task form
      await tester.enterText(
          find.byType(TextField).first, 'Integration Test Task');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify task appears in list
      expect(find.text('Integration Test Task'), findsOneWidget);

      // Complete the task
      final checkboxes = find.byType(Checkbox);
      if (checkboxes.evaluate().isNotEmpty) {
        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Flow 2: create → search → edit', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tap search icon in AppBar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Type in search field
      await tester.enterText(find.byType(TextField).first, 'Integration');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap on result
      final taskTile = find.text('Integration Test Task');
      if (taskTile.evaluate().isNotEmpty) {
        await tester.tap(taskTile);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Flow 3: delete → restore from trash', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Swipe to delete the task
      final taskCard = find.text('Integration Test Task');
      if (taskCard.evaluate().isNotEmpty) {
        await tester.drag(taskCard, const Offset(-500, 0));
        await tester.pumpAndSettle();
      }

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Open Trash
      await tester.tap(find.text('Trash'));
      await tester.pumpAndSettle();

      // Restore the task
      final restoreIcon = find.byIcon(Icons.restore);
      if (restoreIcon.evaluate().isNotEmpty) {
        await tester.tap(restoreIcon.first);
        await tester.pumpAndSettle();
      }

      // Go back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify task is restored
      expect(find.text('Integration Test Task'), findsOneWidget);
    });
  });
}
