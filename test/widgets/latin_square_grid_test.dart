import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/models/latin_square.dart';
import 'package:latin_squares/models/latin_square_generator.dart';
import 'package:latin_squares/widgets/latin_square_grid.dart';

void main() {
  group('LatinSquareGrid Widget Tests', () {
    late LatinSquare testSquare;

    setUp(() {
      testSquare = LatinSquareGenerator.generate(startingOrder: 1);
    });

    // T035: Test for GridView presence
    testWidgets('should contain a GridView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatinSquareGrid(square: testSquare),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });

    // T036: Test for 81 cells
    testWidgets('should display 81 cells', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 600,
              child: LatinSquareGrid(square: testSquare),
            ),
          ),
        ),
      );

      // Find all Container widgets with BoxDecoration that represent cells
      final cellFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration != null &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      );
      expect(cellFinder, findsNWidgets(81));
    });

    // T037: Test for correct number values
    testWidgets('should show correct number values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 600,
              child: LatinSquareGrid(square: testSquare),
            ),
          ),
        ),
      );

      // Verify all numbers 1-9 appear
      for (int i = 1; i <= 9; i++) {
        expect(
          find.text('$i'),
          findsNWidgets(9),
          reason: 'Number $i should appear exactly 9 times',
        );
      }
    });

    // Additional test: responsive sizing
    testWidgets('should use LayoutBuilder for responsive sizing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatinSquareGrid(square: testSquare),
          ),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });

    // Additional test: cell styling
    testWidgets('should have bordered cells', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LatinSquareGrid(square: testSquare),
          ),
        ),
      );

      // Find containers with decoration (bordered cells)
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration != null &&
            widget.decoration is BoxDecoration,
      );
      
      expect(containerFinder, findsAtLeastNWidgets(1));
    });
  });
}
