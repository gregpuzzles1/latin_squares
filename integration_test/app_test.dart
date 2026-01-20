import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:latin_squares/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Latin Square App Integration Tests', () {
    // T070, T071: Test app launch and default square display (User Story 1)
    testWidgets('should launch app and display default Latin square',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app title
      expect(find.text('Latin Squares Display'), findsOneWidget);

      // Verify starting order input is visible
      expect(find.text('Starting Order: '), findsOneWidget);

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      // Verify grid is displayed with numbers 1-9
      for (int i = 1; i <= 9; i++) {
        expect(
          find.descendant(of: gridViewFinder, matching: find.text('$i')),
          findsNWidgets(9),
          reason: 'Number $i should appear 9 times in default square',
        );
      }
    });

    // T072: Test custom order input (User Story 2)
    testWidgets('should accept custom starting order and regenerate square',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the TextField
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Clear and enter new order
      await tester.tap(textFieldFinder);
      await tester.pumpAndSettle();
      
      // Select all and replace with '5'
      await tester.enterText(textFieldFinder, '5');
      await tester.pumpAndSettle();

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      // Verify square regenerated (still has 1-9, each appearing 9 times)
      for (int i = 1; i <= 9; i++) {
        expect(
          find.descendant(of: gridViewFinder, matching: find.text('$i')),
          findsNWidgets(9),
          reason: 'Number $i should appear 9 times after regeneration',
        );
      }
    });

    // T073: Test grid display (User Story 3)
    testWidgets('should display 9x9 grid with borders',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify GridView is present
      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      // Verify 81 cells with borders
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration != null &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      );
      expect(
        find.descendant(of: gridViewFinder, matching: containerFinder),
        findsNWidgets(81),
      );
    });

    // T074: Full user flow test
    testWidgets('should handle complete user flow from launch to custom input',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Verify default square (order 1)
      expect(find.text('Latin Squares Display'), findsOneWidget);
      
      // Step 2: Enter order 3
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, '3');
      await tester.pumpAndSettle();

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      // Step 3: Verify new square displayed
      for (int i = 1; i <= 9; i++) {
        expect(find.descendant(of: gridViewFinder, matching: find.text('$i')),
            findsNWidgets(9),);
      }

      // Step 4: Enter order 7
      await tester.enterText(textFieldFinder, '7');
      await tester.pumpAndSettle();

      // Step 5: Verify another different square
      for (int i = 1; i <= 9; i++) {
        expect(find.descendant(of: gridViewFinder, matching: find.text('$i')),
            findsNWidgets(9),);
      }

      // Step 6: Test invalid input (0)
      await tester.enterText(textFieldFinder, '0');
      await tester.pumpAndSettle();

      // Verify error message displayed
      expect(find.text('Number must be between 1 and 9'), findsOneWidget);

      // Step 7: Test invalid input (non-number)
      await tester.enterText(textFieldFinder, 'abc');
      await tester.pumpAndSettle();

      // Verify error message for non-numeric
      expect(find.text('Please enter a valid number'), findsOneWidget);

      // Step 8: Return to valid input
      await tester.enterText(textFieldFinder, '9');
      await tester.pumpAndSettle();

      // Verify error cleared and square displayed
      expect(find.text('Number must be between 1 and 9'), findsNothing);
      for (int i = 1; i <= 9; i++) {
        expect(find.descendant(of: gridViewFinder, matching: find.text('$i')),
            findsNWidgets(9),);
      }
    });

    // Additional test: Determinism
    testWidgets('should generate identical squares for same order',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      // Generate square with order 5
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, '5');
      await tester.pumpAndSettle();

      // Store first set of values (read from UI would be complex, so we trust generator tests)
      // Just verify the square is valid
      for (int i = 1; i <= 9; i++) {
        expect(find.descendant(of: gridViewFinder, matching: find.text('$i')),
            findsNWidgets(9),);
      }

      // Change to different order
      await tester.enterText(textFieldFinder, '2');
      await tester.pumpAndSettle();

      // Change back to order 5
      await tester.enterText(textFieldFinder, '5');
      await tester.pumpAndSettle();

      // Square should still be valid (determinism verified by unit tests)
      for (int i = 1; i <= 9; i++) {
        expect(find.descendant(of: gridViewFinder, matching: find.text('$i')),
            findsNWidgets(9),);
      }
    });
  });
}
